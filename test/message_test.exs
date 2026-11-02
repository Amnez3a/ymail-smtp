defmodule MessageTest do
  use ExUnit.Case
  alias YsmtpElixir.Message

  test "extract_text from plain base64 mail" do
    b64 =
      "From: a@b.c\r\nSubject: hello\r\nContent-Type: text/plain\r\n" <>
        "Content-Transfer-Encoding: base64\r\n\r\n" <> Base.encode64("hello") <> "\r\n"

    Message.extract_text(:mimemail.decode(b64, encoding: :none))
  end

  test "extract_text from multipart mail" do
    multi =
      "From: a@b.c\r\nSubject: hello\r\nMIME-Version: 1.0\r\n" <>
        "Content-Type: multipart/alternative; boundary=\"xx\"\r\n\r\n" <>
        "--xx\r\nContent-Type: text/plain\r\n\r\nhello\r\n" <>
        "--xx\r\nContent-Type: text/html\r\n\r\n<b>hello</b>\r\n--xx--\r\n"

    Message.extract_text(:mimemail.decode(multi, encoding: :none))
  end
end
