{{/*
Rule 1, chart side. Returns contentExternal.workDir, or aborts the render.

Mirrors assert_not_under_scrapped_data() in
content-external/exporter/api/config.py. Rule 1 is asserted in three places
because one is easy to bypass: docker-compose.yml (A5), here (A8), and the
service itself (A10).

This is a helper that RETURNS the value rather than a standalone guard block,
because the deployment cannot use workDir without going through it — a guard
block can be deleted and everything still renders.

Component-wise, not substring: /var/lib/scrapped-data-archive is a different
directory and is allowed; /uploads/scrapped-data/x is not.
*/}}
{{- define "ckb.contentExternal.workDir" -}}
{{- $wd := .Values.contentExternal.workDir | default "" -}}
{{- if not $wd -}}
{{- fail "contentExternal.workDir must be set — it holds the run lock and the deletion journal" -}}
{{- end -}}
{{- if not (hasPrefix "/" $wd) -}}
{{- fail (printf "contentExternal.workDir must be an absolute path, got %q" $wd) -}}
{{- end -}}
{{- $cleaned := clean $wd -}}
{{- if contains ".." $cleaned -}}
{{- fail (printf "contentExternal.workDir must be normalised with no '..' segments, got %q" $wd) -}}
{{- end -}}
{{- range $part := splitList "/" (lower $cleaned) -}}
{{- if eq $part "scrapped-data" -}}
{{- fail (printf "rule 1: contentExternal.workDir (%q) is inside a 'scrapped-data' tree. Everything written there is zipped into the Global Classifier's payload on the next hourly run, silently. Point it at this service's own PVC." $wd) -}}
{{- end -}}
{{- end -}}
{{- $cleaned -}}
{{- end -}}
