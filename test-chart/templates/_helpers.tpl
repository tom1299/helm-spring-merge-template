{{/*
Expand the name of the chart.
*/}}
{{- define "test-chart.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "test-chart.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "test-chart.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "test-chart.labels" -}}
helm.sh/chart: {{ include "test-chart.chart" . }}
{{ include "test-chart.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "test-chart.selectorLabels" -}}
app.kubernetes.io/name: {{ include "test-chart.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "test-chart.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "test-chart.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
This method converts a multi line string that consits of java properties into a dictionary.
The name of the parameter passed to this methid is javaProperties. The method returns the dictionary.
Example for the input:
``
key1=value1
key2=value2
key3=value3
```
First the method splits the string by new line.
Then it splits each line by the first occurence of the equal sign.
The key and value are then added to the dictionary.
The method ignores lines that do not contain an equal sign.
*/}}
{{- define "test-chart.javaPropertiesToDict" -}}
{{- $result := .result -}}
{{- $javaProperties := .javaProperties | splitList "\n" -}}
{{- range $property := $javaProperties -}}
{{- $keyValue := split "=" $property -}}
{{- if ge (len $keyValue) 2 -}}
{{- $result = set $result ($keyValue)._0 ($keyValue)._1 -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/* This method takes two multi line strings, uses the fucntion javaPropertiesToDictm
 nerges the two dicts where the second one takes precende and returns the merged dict */}}
{{- define "test-chart.mergeJavaProperties" -}}
{{- $dict1 := include "test-chart.javaPropertiesToDict" (dict "javaProperties" .baseProperties) -}}
{{- $dict2 := include "test-chart.javaPropertiesToDict" (dict "javaProperties" .overridenProperties) -}}
{{- merge $dict1 $dict2 -}}
{{- end -}}

{{/* This function takes a dict named test as parameter and adds the key value "test", "testvalue" to it.
The method returns the modified dict. */}}
{{- define "test-chart.addTestValue" -}}
{{- $test := .test -}}
{{- $test = set $test "test" "testvalue" -}}
{{- $test = set $test "test2" "testvalue2" -}}
{{- $javaProperties := .javaProperties | splitList "\n" -}}
{{- range $property := $javaProperties -}}
{{- $keyValue := split "=" $property -}}
{{- if ge (len $keyValue) 2 -}}
{{- $test = set $test ($keyValue)._0 ($keyValue)._1 -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "test-chart.mergeProperties" -}}
{{- $mergedProperties := .mergedProperties -}}
{{- $baseProperties := (dict) }}
{{- include "test-chart.javaPropertiesToDict" (dict "result" $baseProperties "javaProperties" .baseProperties) -}}
{{- $overriddenProperties := (dict) }}
{{- include "test-chart.javaPropertiesToDict" (dict "result" $overriddenProperties "javaProperties" .overriddenProperties) -}}
{{- $mergedProperties = merge $overriddenProperties $baseProperties -}}
{{- range $key, $value := $mergedProperties }}
{{- printf "%s: %s" $key $value | nindent 4}}
{{- end }}
{{- end -}}

{{- define "test-chart.mergePropertiesV2" -}}
{{- $baseProperties := (dict) }}
{{- include "test-chart.javaPropertiesToDict" (dict "result" $baseProperties "javaProperties" .baseProperties) -}}
{{- $overriddenProperties := (dict) }}
{{- include "test-chart.javaPropertiesToDict" (dict "result" $overriddenProperties "javaProperties" .overriddenProperties) -}}
{{- $mergedProperties := merge $overriddenProperties $baseProperties -}}
{{- range $key, $value := $mergedProperties }}
{{- println $key ":" $value}}
{{- end }}
{{- end -}}

{{- define "test-chart.mergePropertiesExtended" -}}
{{- $result := (dict) -}}
{{- range $property := . -}}
{{- $propertyAsDict := (dict) -}}
{{- include "test-chart.javaPropertiesToDict" (dict "result" $propertyAsDict "javaProperties" $property) -}}
{{- $result = merge $propertyAsDict $result -}}
{{- end -}}
{{- range $key, $value := $result }}
{{- println $key ":" $value}}
{{- end }}
{{- end -}}
