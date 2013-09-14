//Do not localize these values by hand.
var areYouSureLocalized = "";
var updateTaxLocalized = "";

function getDocHeight() {
    var D = document;
    return Math.max(
                Math.max(D.body.scrollHeight, D.documentElement.scrollHeight),
                Math.max(D.body.offsetHeight, D.documentElement.offsetHeight),
                Math.max(D.body.clientHeight, D.documentElement.clientHeight)
            );

}

var selectItem = function (tb, ddl) {
    var listControl = $("#" + ddl);
    var textBox = $("#" + tb);
    var selectedValue = textBox.val();
    var exists;

    if (listControl.length) {
        listControl.find('option').each(function () {
            if (this.value == selectedValue) {
                exists = true;
            }
        });
    }

    if (exists) {
        listControl.val(selectedValue).trigger('change');
    }
    else {
        textBox.val('');
    }

    triggerChange(ddl);
}

var triggerChange = function (controlId) {
    var element = document.getElementById(controlId);

    if ('createEvent' in document) {
        var evt = document.createEvent("HTMLEvents");
        evt.initEvent("change", false, true);
        element.dispatchEvent(evt);
    }
    else {
        if ("fireEvent" in element)
            element.fireEvent("onchange");
    }

}

var parseFloat2 = function (arg) {
    return parseFloat(arg || 0);
}

var confirmAction = function () {
    return confirm(areYouSureLocalized);
}


/******************************************************************************************************
DATE EXPRESSION START
******************************************************************************************************/
$(document).ready(function () {
    $(".date").blur(function () {
        if (today == "") return;
        var control = $(this);
        var value = control.val().trim().toLowerCase();
        var result;

        if (value == "d") {
            result = dateAdd(today, "d", 0);
            control.val(result);
            Page_ClientValidate(control.attr("id"));
            return;
        }

        if (value == "m" || value == "+m") {
            control.val(dateAdd(today, "m", 1));
            Page_ClientValidate(control.attr("id"));
            return;
        }

        if (value == "w" || value == "+w") {
            control.val(dateAdd(today, "d", 7));
            Page_ClientValidate(control.attr("id"));
            return;
        }

        if (value == "y" || value == "+y") {
            control.val(dateAdd(today, "y", 1));
            Page_ClientValidate(control.attr("id"));
            return;
        }

        if (value == "-d") {
            control.val(dateAdd(today, "d", -1));
            Page_ClientValidate(control.attr("id"));
            return;
        }

        if (value == "+d") {
            control.val(dateAdd(today, "d", 1));
            Page_ClientValidate(control.attr("id"));
            return;
        }


        if (value == "-w") {
            control.val(dateAdd(today, "d", -7));
            Page_ClientValidate(control.attr("id"));
            return;
        }

        if (value == "-m") {
            control.val(dateAdd(today, "m", -1));
            Page_ClientValidate(control.attr("id"));
            return;
        }

        if (value == "-y") {
            control.val(dateAdd(today, "y", -1));
            Page_ClientValidate(control.attr("id"));
            return;
        }

        if (value.indexOf("d") >= 0) {
            var number = parseInt(value.replace("d"));
            control.val(dateAdd(today, "d", number));
            Page_ClientValidate(control.attr("id"));
            return;
        }

        if (value.indexOf("w") >= 0) {
            var number = parseInt(value.replace("w"));
            control.val(dateAdd(today, "d", number * 7));
            Page_ClientValidate(control.attr("id"));
            return;
        }

        if (value.indexOf("m") >= 0) {
            var number = parseInt(value.replace("m"));
            control.val(dateAdd(today, "m", number));
            Page_ClientValidate(control.attr("id"));
            return;
        }

        if (value.indexOf("y") >= 0) {
            var number = parseInt(value.replace("y"));
            control.val(dateAdd(today, "y", number));
            Page_ClientValidate(control.attr("id"));
            return;
        }
    });
});

function dateAdd(dt, expression, number) {
    var d = Date.parseExact(dt, shortDateFormat);
    var ret;

    if (expression == "d") {
        ret = new Date(d.getFullYear(), d.getMonth(), d.getDate() + parseInt(number));
    }

    if (expression == "m") {
        ret = new Date(d.getFullYear(), d.getMonth() + parseInt(number), d.getDate());
    }

    if (expression == "y") {
        ret = new Date(d.getFullYear() + parseInt(number), d.getMonth(), d.getDate());
    }

    return ret.toString(shortDateFormat);
}

/******************************************************************************************************
DATE EXPRESSION END
******************************************************************************************************/

var showWindow = function (url) {
    newwindow = window.open(url, name, 'width=' + $('html').width() + ',height=' + $('html').height() + ',toolbar=0,menubar=0,location=0,scrollbars=1,resizable=1');
    newwindow.moveTo(0, 0);
    if (window.focus) { newwindow.focus() }
}


$(document).ready(function () {
    setNumberFormat();
    Sys.WebForms.PageRequestManager.getInstance().add_endRequest(Page_EndRequest);
});

function Page_EndRequest(sender, args) {
    setNumberFormat();
}

var setNumberFormat = function () {
    $('input.number').number(true, decimalPlaces, decimalSeparator, thousandSeparator);
}




/******************************************************************************************************
Chart BEGIN
******************************************************************************************************/
var chartColors = ["#B54BDB", "#272EE8", "#67A12D", "#CCD439", "#51B0A6", "#D49B39", "#48BD59", "#48BD9A", "#488CBD", "#48B7BD", "#E82727", "#E84898", "#E848E3", "#B07951", "#99CC33", "#E6892C", "#97BBCD"];

function getFillColor(index) {
    var color = hexToRgb(chartColors[index]);
    var opacity = 0.5;
    return "rgba(" + color.r + "," + color.g + "," + color.b + "," + opacity + ")";
}

function hexToRgb(hex) {
    // Expand shorthand form (e.g. "03F") to full form (e.g. "0033FF")
    var shorthandRegex = /^#?([a-f\d])([a-f\d])([a-f\d])$/i;
    hex = hex.replace(shorthandRegex, function (m, r, g, b) {
        return r + r + g + g + b + b;
    });

    var result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
    return result ? {
        r: parseInt(result[1], 16),
        g: parseInt(result[2], 16),
        b: parseInt(result[3], 16)
    } : null;
}

function prepareChart(datasourceId, canvasId, legendId, type) {
    var table = $("#" + datasourceId);
    var labels = [];
    var data = [];
    var datasets = [];
    var title;
    var index = 0;

    //Loop through the table header for labels.
    table.find("thead th").each(function () {

        //Ignore the first column of the header
        if (index > 0) {
            //Create labels from header row columns.
            labels.push($(this).html());
        }

        index++;
    });

    //Reset the counter.
    index = 0;

    //Loop through each row of the table body.
    table.find("tbody tr").each(function () {

        //Get an instance of the current row
        var row = $(this);

        //The first column of each row is the legend.
        title = row.find(">:first-child").html();

        //Reset the data object's value from the previous iteration.
        data = [];
        //Loop through the row columns.
        row.find("td").each(function () {
            //Get data from this row.
            data.push($(this).html());
        });

        //Create a new dataset representing this row.
        var dataset =
            {
                fillColor: getFillColor(index),
                strokeColor: chartColors[index],
                pointColor: chartColors[index],
                data: data,
                title: title
            };

        //Add the dataset object to the array object.
        datasets.push(dataset);

        index++;
    });


    var data = {
        labels: labels,
        datasets: datasets
    }

    var ctx = document.getElementById(canvasId).getContext("2d");

    switch (type) {
        case "line":
            new Chart(ctx).Line(data);
            break;
        case "radar":
            new Chart(ctx).Radar(data);
            break;
        default:
            new Chart(ctx).Bar(data);
            break;
    }

    legend(document.getElementById(legendId), data);
    table.hide();
}

/******************************************************************************************************
Chart END
******************************************************************************************************/
