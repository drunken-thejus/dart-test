import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

void main() async {
  var yt = YoutubeExplode();

  var handler = (Request request) async {
    var url = request.url.queryParameters['url'];
    if (url == null) {
      return Response.badRequest(body: 'Provide ?url=');
    }

    var video = await yt.videos.get(url);
    var manifest = await yt.videos.streamsClient.getManifest(video.id);
    var audio = manifest.audioOnly.withHighestBitrate();

    var data = {
      'title': video.title,
      'artist': video.author,
      'thumbnail': video.thumbnails.highResUrl,
      'duration': video.duration.toString(),
      'audio_url': audio.url.toString(),
      'bitrate': audio.bitrate.bitsPerSecond,
    };

    return Response.ok(
      jsonEncode(data),
      headers: {'Content-Type': 'application/json'},
    );
  };

  await io.serve(handler, '0.0.0.0', 8080);
}
