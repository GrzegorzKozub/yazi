local M = {}

function M:peek(job)
  local start, cache = os.clock(), ya.file_cache(job)
  if not cache then
    return
  end
  local ok, err = self:preload(job)
  if not ok or err then
    return ya.preview_widget(job, err)
  end
  ya.sleep(math.max(0, rt.preview.image_delay / 1000 + start - os.clock()))
  local _, err = ya.image_show(cache, job.area)
  ya.preview_widget(job, err)
end

function M:preload(job)
  local cache = ya.file_cache(job)
  if not cache then
    return true
  end
  local cha = fs.cha(cache)
  if cha and cha.len > 0 then
    return true
  end
  local status, err = Command('ffmpeg'):arg({
    '-v',
    'quiet',
    '-i',
    tostring(job.file.url),
    '-frames:v',
    1,
    '-vf',
    string.format(
      "scale='min(%d,iw)':'min(%d,ih)':force_original_aspect_ratio=decrease:flags=fast_bilinear",
      rt.preview.max_width,
      rt.preview.max_height
    ),
    '-q:v',
    31 - math.floor(rt.preview.image_quality * 0.3),
    '-f',
    'image2',
    '-y',
    tostring(cache),
  }):status()
  if not status then
    return true, Err('Failed to start `ffmpeg`, error: %s', err)
  elseif not status.success then
    return false, Err('`ffmpeg` exited with error code: %s', status.code)
  else
    return true
  end
end

return M
