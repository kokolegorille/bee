defmodule BeeWeb.PageLive do
  use BeeWeb, :live_view

  def mount(_parasm, _session, socket) do
    {:ok, assign(socket, text: nil, task: nil, result: nil)}
  end

  def handle_event("predict", params, socket) do
    case params["text"] do
      "" ->
        {:noreply, assign(socket, text: nil, task: nil, result: nil)}

      text ->
        task = Task.async(fn -> Nx.Serving.batched_run(BeeTextServing, text) end)
        {:noreply, assign(socket, text: text, task: task, result: nil)}
    end
  end

  def handle_info({ref, result}, socket) when socket.assigns.task.ref == ref do
    {:noreply, assign(socket, task: nil, result: result)}
  end

  def handle_info(_, socket) do
    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="h-screen m-auto flex items-center justify-center antialiased">
      <div class="flex flex-col h-1/2 w-1/2">
        <form class="m-0 flex space-x-2" phx-change="predict">
          <input
            class="block w-full p-2.5 bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg"
            type="text"
            name="text"
            phx-debounce="300"
            value={@text}
          />
        </form>
        <div class="mt-2 flex space-x-1.5 items-center text-gray-600 text-lg">
          <span>Emotion:</span>
          <%= if @task do %>
            <.spinner />
          <% else %>
            <%= if @result do %>
              <ul>
                <%= for prediction <- @result.predictions do %>
                  <li>
                    <%= prediction.label %>
                    <%= Float.round(prediction.score, 5) %>
                  </li>
                <% end %>
              </ul>
            <% end %>
          <% end %>
        </div>
      </div>
    </div>
    """
  end
end
