defmodule BeeWeb.StableDiffusionLive do
  use BeeWeb, :live_view
  require Logger

  def mount(_parasm, _session, socket) do
    {:ok, assign(socket, text: nil, negative_text: nil, task: nil, result: nil)}
  end

  def handle_event("predict", params, socket) do
    case {params["text"], params["negative_text"]} do
      {"", ""} ->
        {:noreply, assign(socket, text: nil, negative_text: nil, task: nil, result: nil)}
      {text, negative_text} ->
        Logger.info("Start prediction")
        task = Task.async(fn -> Nx.Serving.batched_run(BeeStableDiffusionServing, %{prompt: text, negative_prompt: negative_text}) end)
        {:noreply, assign(socket, text: text, negative_text: negative_text, task: task, result: nil)}
    end
  end
  def handle_info({ref, result}, socket) when socket.assigns.task.ref == ref do
    Logger.info("#{__MODULE__} received result #{inspect result}")
    {:noreply, assign(socket, task: nil, result: result)}
  end

  def handle_info(params, socket) do
    Logger.info("#{__MODULE__} received info #{inspect params}")
    {:noreply, socket}
  end
  def render(assigns) do
    ~H"""
    <div class="h-screen m-auto flex items-center justify-center antialiased">
      <div class="flex flex-col h-1/2 w-1/2">
        <form class="m-0 flex space-x-2" phx-submit="predict">
          <input
            class="block w-full p-2.5 bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg"
            type="text"
            name="text"
            phx-debounce="300"
            value={@text}
          />
          <input
            class="block w-full p-2.5 bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg"
            type="text"
            name="negative_text"
            phx-debounce="300"
            value={@negative_text}
          />
          <button phx-disable-with="Saving...">Save Customer</button>
        </form>
        <div class="mt-2 flex space-x-1.5 items-center text-gray-600 text-lg">
          <span>Result:</span>
          <%= if @task do %>
            <.spinner />
          <% else %>
            <%= if @result do %>
              <%= inspect @result %>
            <% end %>
          <% end %>
        </div>
      </div>
    </div>
    """
  end
end
