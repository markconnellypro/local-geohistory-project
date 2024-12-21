var chart = c3.generate({
    bindto: "#chart",
    data: {
        x: 'x',
        columns: columnData
    },
    axis: {
        x: {
            label: xLabel,
            position: "outer-center"
        },
        y: {
            label: yLabel,
            position: "outer-middle"
        }
    },
    legend: {
        show: showLegend
    }
});

function reloadData(series, x, data) {
    if (x[0] == 0) {
        if (lastLayer != "") {
            chart.unload({
                ids: lastLayer
            });
            lastLayer = "";
        }
    } else {
        x.unshift("x");
        data.unshift(series);
        var colorData = [];
        colorData[series] = '#BE3A34';
        var axisData = [];
        axisData[series] = false;
        chart.load({
            unload: lastLayer,
            columns: [
                x,
                data
            ],
            colors: colorData,
            axis: axisData,
            legend: {
                show: true
            }
        });
        lastLayer = series;
    }
}

$(function () {
    $('.chartdownload').click(function (event) {
        event.preventDefault();
        var a = document.createElement('a');
        document.body.appendChild(a);
        a.style = 'display: none';
        var downloadString = "Jurisdiction,Year,Count\n";
        $.each(chart.internal.data.targets, function (seriesIndex, seriesElement) {
            $.each(seriesElement.values, function (rowIndex, rowElement) {
                if (rowElement.value !== 0) {
                    downloadString += '"' + rowElement.id + '",' + rowElement.x + ',' + rowElement.value + "\n";
                }
            });
        });
        var blob = new Blob([downloadString], { type: 'text/csv' }),
            url = window.URL.createObjectURL(blob);
        a.href = url;
        a.download = 'chart.csv';
        a.click();
        setTimeout(function () {
            window.URL.revokeObjectURL(url);
        }, 1000);
    });
});