document.getElementById('courseform').reset();
document.getElementById('distanceform').reset();

$(function () {
    $("input[name=metesdegreetype]").change(function () {
        $(".metesdegree").each(function (element) {
            deg = parseFloat($(this).attr('data-deg'));
            if (!isNaN(deg)) {
                ns = $(this).attr('data-ns');
                ew = $(this).attr('data-ew');
                switch ($("input[name=metesdegreetype]:radio:checked").val()) {
                    case "1": // Degrees
                        $(this).html(ns + ' ' + deg + '&deg; ' + ew);
                        break;
                    case "2": // Degrees & minutes
                        degwhole = Math.floor(deg);
                        min = +((deg - degwhole) * 60).toFixed(9);
                        $(this).html(ns + ' ' + degwhole + '&deg; ' + min + "' " + ew);
                        break;
                    case "3": // Degrees, minutes, & seconds
                        degwhole = Math.floor(deg);
                        min = (deg - degwhole) * 60;
                        minwhole = Math.floor(+min.toFixed(9));
                        sec = +((min - minwhole) * 60).toFixed(9);
                        $(this).html(ns + ' ' + degwhole + '&deg; ' + minwhole + "' " + sec + '" ' + ew);
                        break;
                }
            }
        });
    });
    $("input[name=metesfoottype]").change(function () {
        $(".metesfoot").each(function (element) {
            ft = parseFloat($(this).attr('data-ft'));
            if (!isNaN(ft)) {
                switch ($("input[name=metesfoottype]:radio:checked").val()) {
                    case "1": // Feet
                        $(this).html(ft + ' <span class="i">ft.</span>');
                        break;
                    case "2": // Feet & inches
                        ftwhole = Math.floor(ft);
                        inch = +((ft - ftwhole) * 12).toFixed(9);
                        $(this).html(ftwhole + ' <span class="i">ft.,</span> ' + inch + ' <span class="i">in.</span>');
                        break;
                    case "3": // Rods
                        rd = +(ft / 16.5).toFixed(9);
                        $(this).html(rd + ' <span class="i">rd.</span>');
                        break;
                    case "4": // Rods & feet
                        rd = ft / 16.5;
                        rdwhole = Math.floor(+(rd).toFixed(9));
                        ft = +((rd - rdwhole) * 16.5).toFixed(9);
                        $(this).html(rdwhole + ' <span class="i">rd.,</span> ' + ft + ' <span class="i">ft.</span>');
                        break;
                    case "5": // Rods, feet, & inches
                        rd = ft / 16.5;
                        rdwhole = Math.floor(+rd.toFixed(9));
                        ft = (rd - rdwhole) * 16.5;
                        ftwhole = Math.floor(+ft.toFixed(9));
                        inch = +((ft - ftwhole) * 12).toFixed(9);
                        $(this).html(rdwhole + ' <span class="i">rd.,</span> ' + ftwhole + ' <span class="i">ft.,</span> ' + inch + ' <span class="i">in.</span>');
                        break;
                    case "6": // Chains
                        ch = +(ft / 66).toFixed(9);
                        $(this).html(ch + ' <span class="i">ch.</span>');
                        break;
                }
            }
        });
    });
});
