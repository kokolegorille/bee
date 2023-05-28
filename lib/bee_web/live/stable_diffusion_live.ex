defmodule BeeWeb.StableDiffusionLive do
  use BeeWeb, :live_view

  def mount(_parasm, _session, socket) do
    {:ok, assign(socket, text: nil, negative_text: nil, task: nil, result: nil)}
  end

  def handle_event("predict", params, socket) do
    case {params["text"], params["negative_text"]} do
      {"", ""} ->
        {:noreply, assign(socket, text: nil, negative_text: nil, task: nil, result: nil)}
      {text, negative_text} ->
        task = Task.async(fn -> Nx.Serving.batched_run(BeeStableDiffusionServing, %{prompt: text, negative_prompt: negative_text}) end)
        {:noreply, assign(socket, text: text, negative_text: negative_text, task: task, result: nil)}
    end
  end
  def handle_info({ref, result}, socket) when socket.assigns.task.ref == ref do
    images = persists_result(result.results)
    {:noreply, assign(socket, task: nil, result: images)}
  end

  def handle_info(_params, socket) do
    {:noreply, socket}
  end
  def render(assigns) do
    ~H"""
    <div class="m-auto flex items-center justify-center antialiased">
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
          <button phx-disable-with="Saving...">Predict</button>
        </form>
        <div class="mt-2 flex space-x-1.5 items-center text-gray-600 text-lg">
          <span>Result:</span>
          <%= if @task do %>
            <.spinner />
          <% else %>
            <%= if @result do %>
              <%= for image <- @result do %>
                <ul>
                  <li>
                    {image}
                    <img src={image} />
                  </li>
                </ul>
              <% end %>
            <% end %>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  defp persists_result(results) do
    results
    |> Enum.map(fn r ->
      {:ok, image} = Image.from_nx(r.image)

      name = "#{Ecto.UUID.generate()}.jpg"
      path = Path.join([:code.priv_dir(:bee), "static", "images", name])
      url = Path.join("/images", name)

      case Image.write(image, path) do
        {:ok, _} -> url
        error -> IO.inspect(error); nil
      end
    end)
    |> Enum.reject(& is_nil(&1))
  end
end
