defmodule TestGenerateMsgId do
  use ExUnit.Case
  alias YsmtpElixir.Message

  test "generate_msg_id" do
    a = Message.generate_msg_id("example.com")
    b = Message.generate_msg_id("example.com")

    refute a == b
    assert a =~ ~r/^[0-9a-f]{32}-\d+@example\.com$/
  end
end
