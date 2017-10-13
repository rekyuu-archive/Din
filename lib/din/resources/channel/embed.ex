defmodule Din.Resources.Channel.Embed do
  alias Din.Resources.Channel.Embed

  @typedoc "title of embed"
  @type title :: String.t

  @typedoc "type of embed (always \"rich\" for webhook embeds)"
  @type type :: String.t

  @typedoc "description of embed"
  @type description :: String.t

  @typedoc "url of embed"
  @type url :: String.t

  @typedoc "timestamp of embed content"
  @type timestamp :: String.t

  @typedoc "color code of the embed"
  @type color :: integer

  @typedoc "footer information"
  @type footer :: Embed.Footer.t

  @typedoc "image information"
  @type image :: Embed.Image.t

  @typedoc "thumbnail information"
  @type thumbnail :: Embed.Thumbnail.t

  @typedoc "video information"
  @type video :: Embed.Video.t

  @typedoc "provider information"
  @type provider :: Embed.Provider.t

  @typedoc "provider information"
  @type author :: Embed.Author.t

  @typedoc "fields information"
  @type fields :: list(Embed.Field.t)

  @enforce_keys [:title, :type, :description, :url, :timestamp, :color, :footer, :image, :thumbnail, :video, :provider, :author, :fields]
  defstruct [:title, :type, :description, :url, :timestamp, :color, :footer, :image, :thumbnail, :video, :provider, :author, :fields]
  @type t :: %__MODULE__{
    title: title,
    type: type,
    description: description,
    url: url,
    timestamp: timestamp,
    color: color,
    footer: footer,
    image: image,
    thumbnail: thumbnail,
    video: video,
    provider: provider,
    author: author,
    fields: fields
  }
end
