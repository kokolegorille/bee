defmodule BeeWeb.ImageLive do
  use BeeWeb, :live_view

  @impl true
  def mount(_parasm, _session, socket) do
    {
      :ok,
      socket
      |> assign(text: nil, task: nil)
      |> allow_upload(:image,
        accept: :any,
        max_entries: 1,
        progress: &handle_progress/3,
        auto_upload: true
      )
    }
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex items-center justify-center antialiased">
      <div class="flex flex-col items-center w-1/2">
        <form class="m-0 flex flex-col items-center space-y-2" phx-change="noop" phx-submit="noop">
          <.image_input id="image" upload={@uploads.image} height={224} width={224} />
        </form>
        <div class="mt-6 flex space-x-1.5 items-center text-gray-600 text-lg">
          <span>Label:</span>
          <%= if @task do %>
            <.spinner />
          <% else %>
            <span class="text-gray-900 font-medium"><%= @text || "?" %></span>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  defp image_input(assigns) do
    ~H"""
    <div
      id={"#{@id}-root"}
      class="inline-flex p-4 border-2 border-dashed border-gray-200 rounded-lg cursor-pointer"
      phx-hook="ImageInput"
      data-height={@height}
      data-width={@width}
    >
      <.live_file_input upload={@upload} class="hidden" />
      <input type="file" data-el-input class="hidden" />
      <div
        class="h-[300px] w-[300px] flex items-center justify-center"
        id={"#{@id}-preview"}
        phx-update="ignore"
        data-el-preview
      >
        <div class="text-gray-500 text-center">
          Drag an image file here or click to open file browser
        </div>
      </div>
    </div>
    """
  end

  def handle_progress(:image, entry, socket) do
    if entry.done? do
      socket
      |> consume_uploaded_entries(:image, fn %{path: path}, _entry ->
        {:ok, File.read!(path)}
      end)
      |> case do
        [binary] ->
          image = decode_as_tensor(binary)
          task = Task.async(fn -> Nx.Serving.batched_run(BeeImageServing, image) end)
          {:noreply, assign(socket, text: nil, task: task)}

        [] ->
          {:noreply, socket}
      end
    else
      {:noreply, socket}
    end
  end

  defp decode_as_tensor(<<height::32-integer, width::32-integer, data::binary>>) do
    data |> Nx.from_binary(:u8) |> Nx.reshape({height, width, 3})
  end

  @impl true
  def handle_event("noop", %{}, socket) do
    # We need phx-change and phx-submit on the form for live uploads,
    # but we make predictions immediately using :progress, so we just
    # ignore this event
    {:noreply, socket}
  end

  @impl true
  def handle_info({ref, result}, %{assigns: %{task: task}} = socket) when task.ref == ref do
    Process.demonitor(ref, [:flush])
    %{predictions: [%{label: label} | _]} = result
    {:noreply, assign(socket, text: label, task: nil)}
  end

  def handle_info(_, socket) do
    {:noreply, socket}
  end
end
