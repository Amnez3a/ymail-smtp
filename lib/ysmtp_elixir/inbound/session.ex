defmodule YsmtpElixir.Inbound.Session do
  @behaviour :gen_smtp_server_session
  require Logger

  defstruct from: nil,
            to: [],
            sender: nil,
            local_domain: ""

  @impl true
  def init(hostname, _session_count, _client_ip, options) do
    Logger.info("[  SERVER  ] new session")
    banner = "#{hostname} ESMTP ySMTP"

    state = %__MODULE__{
      local_domain: Keyword.get(options, :local_domain, "")
    }

    {:ok, banner, state}
  end

  @impl true
  def handle_HELO(_hostname, state), do: {:ok, 65535, state}
  @impl true
  def handle_EHLO(_hostname, extensions, state), do: {:ok, extensions, state}

  @impl true
  def handle_MAIL(from, %__MODULE__{} = state) do
    Logger.info("[  SERVER/SESSION/MAIL  ] mail from: #{from}")
    new_state = %{state | from: from}
    {:ok, new_state}
  end

  @impl true
  def handle_MAIL_extension(_extension, state), do: {:ok, state}

  @impl true
  def handle_RCPT(to, %__MODULE__{} = state) do
    Logger.info("[  SERVER/SESSION/RCPT  ] mail to: #{to}")
    new_state = %{state | to: [to | state.to]}
    {:ok, new_state}
  end

  @impl true
  def handle_RCPT_extension(_extension, state), do: {:ok, state}

  @impl true
  def handle_RSET(state), do: %{state | from: nil, to: []}

  @impl true
  def handle_STARTTLS(state), do: state

  @impl true
  def handle_VRFY(_addres, state), do: {:error, ~c"502 VRFY not supported", state}

  @impl true
  def handle_other(_verb, _args, state), do: {~c"500 unknown command", state}

  @impl true
  def terminate(reason, state), do: {:ok, reason, state}

  @impl true
  def code_change(_old_svn, state, _extra), do: {:ok, state}

  @impl true
  def handle_DATA(_from, _to, <<>>, state) do
    {:error, "552 empty letter", state}
  end

  def handle_DATA(from, to, data, state) do
    Logger.info(
      "[  SERVER/SESSION/DATA  ] #{from} -> #{Enum.join(to, ", ")}, #{byte_size(data)} bytes"
    )

    {:ok, "250 OK", state}
  end
end

defmodule YsmtpElixir.Inbound.EmailDecoder do
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
