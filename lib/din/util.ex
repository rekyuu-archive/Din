defmodule Din.Util do
  @moduledoc """
  Utility functions.
  """
  
  @doc """
  Takes a filepath and turns it into base64 url data.
  """
  @spec build_base64_image_data(binary) :: String.t
  def build_base64_image_data(image_path) do    
    image_type = cond do
      Path.extname(image_path) in [".jpg", ".jpeg"] -> "jpeg"
      Path.extname(image_path) == ".gif" -> "gif"
      Path.extname(image_path)  == ".png" -> "png"
      true -> "not a supported image"
    end
    
    cond do
      image_type in ["jpeg", "gif", "png"] ->
        {:ok, image} = File.read(image_path)
        image_encoded = Base.encode64(image)
        
        "data:image/#{image_type};base64,#{image_encoded}"
      true -> IO.inspect "not a supported image", label: "error"
    end
  end
end