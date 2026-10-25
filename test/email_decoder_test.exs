defmodule EmailDecoderTest do
  alias YsmtpElixir.EmailDecoder
  use ExUnit.Case

  test "base64" do
    assert EmailDecoder.decode_body("base64", "aGVsbG8gd29ybGQ=") == {:ok, "hello world"}
    assert EmailDecoder.decode_body("base64", "aGVs\r\nbG8=") == {:ok, "hello"}
    assert EmailDecoder.decode_body("base64", "###") == {:error, :invalid_base64}
  end

  test "quoted-printable" do
    assert EmailDecoder.decode_body("quoted-printable", "caf=C3=A9") ==
             {:ok, "café"}

    assert EmailDecoder.decode_body("quoted-printable", "=ZZ") ==
             {:error, :invalid_quoted_printable}

    assert EmailDecoder.decode_body("quoted-printable", "длинная=\r\nстрока") ==
             {:ok, "длиннаястрока"}
  end
end
