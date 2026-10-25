defmodule YsmtpElixir.EmailDecoder do
  @doc """
  декодирует тему письма (subject) из формата RFC 2047
  """
  def decode_subject(raw_subject) do
    case :mimemail.decode(["Subject: #{raw_subject}"]) do
      [{"Subject", decoded_subject}] -> decoded_subject
      _error -> raw_subject
    end
  end

  @doc """
  декодирует тело письма на основе Content-Transfer-Encoding
  """
  def decode_body(encoding, body) do
    case String.downcase(String.trim(encoding || "")) do
      "base64" ->
        case Base.decode64(body, ignore: :whitespace) do
          {:ok, decoded} -> {:ok, decoded}
          :error -> {:error, :invalid_base64}
        end

      "quoted-printable" ->
        try do
          {:ok, :mimemail.decode_quoted_printable(body)}
        catch
          :throw, :badchar -> {:error, :invalid_quoted_printable}
        end

      _default ->
        {:ok, body}
    end
  end
end
