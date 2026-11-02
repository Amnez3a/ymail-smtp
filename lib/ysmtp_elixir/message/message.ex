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

  def extract_text({"text", "plain", _headers, _params, body}), do: body

  def extract_text({"multipart", _subtype, _headers, _params, parts}) when is_list(parts) do
    Enum.find_value(parts, &extract_text/1)
  end

  def extract_text(_other), do: nil

  def parse(data) do
    try do
      decoded = :mimemail.decode(data, encoding: :none)
      {:ok, decoded}
    catch
      _kind, _reason -> {:error, :unparseable}
    end
  end

  defp subject(headers) do
    case List.keyfind(headers, "Subject", 0) do
      {"Subject", value} -> value
      nil -> ""
    end
  end
end
