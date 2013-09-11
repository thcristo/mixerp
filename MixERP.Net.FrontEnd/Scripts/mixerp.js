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

