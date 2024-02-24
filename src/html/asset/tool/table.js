$(function () {

    function getDataTableSortString(n, multiplier) {
        if (n !== '') {
            n = n.toString();
            try {
                var startNumber = n.match('^[0-9]+');
                startNumber = startNumber.shift();
                startNumberLength = startNumber.length;
                startNumber = parseInt(startNumber).toString();
            } catch (error) {
                startNumber = 'AAAAAAAAAAAAAAA';
                startNumberLength = 0;
            }
            n = n.substring(startNumberLength);
            try {
                var endNumber = n.match('[0-9]+$');
                endNumber = endNumber.shift();
                endNumberLength = endNumber.length;
                endNumber = parseInt(endNumber).toString();
            } catch (error) {
                endNumber = '0';
                endNumberLength = 0;
            }
            n = n.substring(0, n.length - endNumberLength);
            n = startNumber.padStart(15, '0') + n.padEnd(15, '0') + endNumber.padStart(15, '0');
        } else if (multiplier == -1) {
            n = '000000000000000000000000000000000000000000000';
        } else {
            n = 'ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ';
        }
        return n;
    }

    function getDataTableSortOrder(x, y, multiplier) {
        x = $.trim(x);
        x = getDataTableSortString(x, multiplier);
        y = $.trim(y);
        y = getDataTableSortString(y, multiplier);
        return ((x < y) ? -1 : ((x > y) ? 1 : 0));
    }

    jQuery.fn.dataTableExt.oSort['emptylast-asc'] = function (x, y) {
        return getDataTableSortOrder(x, y, 1);
    }

    jQuery.fn.dataTableExt.oSort['emptylast-desc'] = function (y, x) {
        return getDataTableSortOrder(x, y, -1);
    }

    $('.normal').DataTable({
        'info': false,
        'paging': false,
        'searching': false,
        'order': [],
        "language": {
            "emptyTable": "Sorry, no records found!"
        },
        'columnDefs': [
            { className: 'dt-head-nowrap', "sType": "emptylast", 'targets': ['_all'] }
        ],
        'initComplete': function (settings, json) {
            $(this).wrap('<div class="tablewrap"></div>');
        }
    });

    $('.normalsort').DataTable({
        'info': false,
        'paging': false,
        'searching': false,
        'order': [[0, 'asc']],
        "language": {
            "emptyTable": "Sorry, no records found!"
        },
        'columnDefs': [
            { className: 'dt-head-nowrap', "sType": "emptylast", 'targets': ['_all'] }
        ],
        'initComplete': function (settings, json) {
            $(this).wrap('<div class="tablewrap"></div>');
        }
    });

    $('.search').DataTable({
        'info': false,
        'paging': false,
        'order': [],
        "language": {
            "emptyTable": "Sorry, no records found!"
        },
        'columnDefs': [
            { className: 'dt-head-nowrap', "sType": "emptylast", 'targets': ['_all'] }
        ],
        'initComplete': function (settings, json) {
            $(this).wrap('<div class="tablewrap"></div>');
        }
    });

    $('.lawgroup').DataTable({
        'info': false,
        'paging': false,
        'searching': false,
        'ordering': false,
        "language": {
            "emptyTable": "Sorry, no records found!"
        },
        'columnDefs': [
            { className: 'dt-head-nowrap', 'targets': ['_all'] }
        ],
        'initComplete': function (settings, json) {
            $(this).wrap('<div class="tablewrap"></div>');
        }
    });

});
