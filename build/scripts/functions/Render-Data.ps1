function Render-Data($data) {
    $output = @()

    foreach ($key in $data.keys) {
        $item = $data[$key]

        $prepend = ""
        if (!$item.required) {
            $prepend = "# "
        }

        if (![string]::isNullOrEmpty($item.description)) {
            $output += "# {0}" -f $item.description
        }

        # ensure that True and False are correctly cased
        $value = $item.value
        if ($value.tostring() -eq "True" -or $value.tostring() -eq "False") {
            $value = $value.tostring().tolower()
        }

        $output += $config[$Shell].template -f $prepend, $key, $value
    }

    return $output
}