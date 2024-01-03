import Pkg

Pkg.add(["Genie", "HTTP", "JSON"])

using Genie, HTTP, JSON

SPOTIFY_API_URL = "https://api.spotify.com/v1/"

function encode_ids(ids)
	return join(map(x -> replace(x, '/' => "%2F", '+' => "%2B", ' ' => "%20"), ids), ",")
end

function api_http_get_request(endpoint, headers)
	url = SPOTIFY_API_URL * endpoint
	response = HTTP.get(url, headers)

	if response.status == 200
		return JSON.parse(String(response.body))
	else
	    println("Error al obtener los datos de $endpoint")
		return nothing
	end
end

function get_track_info(track_id, headers)
    return api_http_get_request("tracks/$track_id", headers)
end

function get_track_audio_features(track_id, headers)
    return api_http_get_request("audio-features/$track_id", headers)
end

function get_favorite_tracks(headers)
    return api_http_get_request("me/top/tracks?limit=50", headers)
end

function get_audio_features_multiple_tracks(ids, headers)
    return api_http_get_request("audio-features?ids=$(encode_ids(ids))", headers)
end

function get_recommendations(ids, headers)
    return api_http_get_request("recommendations?seed_tracks=$(encode_ids(ids))&limit=100", headers)["tracks"]
end

route("/fav") do
    token = params(:token, nothing)

	headers = Dict(
			"Authorization" => "Bearer $token",
			"Content-Type" => "application/json"
		    )

    get_favorite_tracks(headers) |> json
end

route("/") do
    return "Hi!"
end

Genie.config.run_as_server = true
Genie.up(8000, "0.0.0.0")
