defmodule Din.Util do
  @moduledoc """
  Utility functions.
  """
  
  @doc """
  Builds base64 image data specified by Discord.
  """
  @spec build_base64_image_data(binary) :: String.t
  def build_base64_image_data(img) do
    image_type = cond do
      Path.extname(img) in [".jpg", ".jpeg"] -> "jpeg"
      Path.extname(img) == ".gif" -> "gif"
      Path.extname(img)  == ".png" -> "png"
      true -> "not a supported image"
    end
    
    cond do
      image_type in ["jpeg", "gif", "png"] ->
        "data:image/#{image_type};base64,#{Base.url_encode64(img)}"
      true -> IO.inspect "not a supported image", label: "error"
    end
  end
end