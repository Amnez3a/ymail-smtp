defmodule YsmtpElixir.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      :gen_smtp_server.child_spec(
        :ysmtp_inbound,
        YsmtpElixir.Inbound.Session,
        port: 2525,
        domain: ~c"localhost",
        sessionoptions: [callbackoptions: [local_domain: "yellowhat.cz"]]
      )
    ]

    opts = [strategy: :one_for_one, name: YsmtpElixir.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
