defmodule YsmtpElixir.Message do
  def generate_msg_id(domain) do
    bytes_hex =
      :crypto.strong_rand_bytes(16)
      |> Base.encode16(case: :lower)

    nano_time = System.system_time()

    "#{bytes_hex}-#{nano_time}@#{domain}"
  end

  def get_domain(email) when is_binary(email) do
    case String.split(email, "@") do
      [_, domain] -> {:ok, domain}
      _ -> {:error, :invalid_email}
    end
  end
end
