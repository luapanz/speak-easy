// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require formvalidation.io/formValidation.min
//= require formvalidation.io/framework/bootstrap.min
//= require select2
//= require load-image.all.min
//= require phone-utils
//= require moment
//= require snackbar

//= require rrt

//= require_tree .
//= require bootstrap-datetimepicker
//= require pickers
//= require jquery.scrollTo.min
//= require daterangepicker
//= require jquery.scombobox.min
//= require papaparse.min
//= require jquery-cropper.js
//= require cropper.js
//= require tinymce-jquery

$().ready(function () {
    $('#user_photo').change(function (e) {
        var file = e.target.files[0];
        var $preview = $('#user_photo_preview');
        var options = {canvas: true, maxWidth: $preview.width()};

        loadImage.parseMetaData(file, function (data) {
            if (data.exif) {
                options.orientation = data.exif.get('Orientation')
            }

            photo(
                e.target.files[0],
                function (img) {
                    $preview.html(img);
                },
                options
            )
        });
    });

    //TODO: Split to single function
    $('#location_logo').change(function (e) {
        var file = e.target.files[0];
        var $preview = $('#location_photo_preview');
        var options = {canvas: true, maxWidth: $preview.width()};

        loadImage.parseMetaData(file, function (data) {
            if (data.exif) {
                options.orientation = data.exif.get('Orientation')
            }

            loadImage(
                e.target.files[0],
                function (img) {
                    $preview.html(img);
                },
                options
            )
        });
    });

    $('#business_logo').change(function (e) {
        var file = e.target.files[0];
        var $preview = $('#business_photo_preview');
        var options = {canvas: true, maxWidth: $preview.width()};

        loadImage.parseMetaData(file, function (data) {
            if (data.exif) {
                options.orientation = data.exif.get('Orientation')
            }

            loadImage(
                e.target.files[0],
                function (img) {
                    $preview.html(img);
                },
                options
            )
        });
    });

    var isVerifyEmailRequestSent = false;
    $('div.alert a').click(function () {
        $.ajax({
                url: '/ajax/verify_email',
                type: 'POST',
                data: JSON.stringify({username: $(this).data('username')}),
                dataType: "json",
                contentType: 'application/json'
            })
            .done(function () {
                $('div.alert')
                    .removeClass('alert-warning')
                    .addClass('alert-success')
                    .find('span.message')
                    .html('The email has been sent');
            })
            .fail(function (data, error) {
                $('div.alert')
                    .removeClass('alert-warning')
                    .addClass('alert-danger')
                    .find('span.message')
                    .html(data.responseJSON.message);
            });
    });

    $('#campaign_photo').change(function (e) {
        var file = e.target.files[0];
        var $preview = $('#offerPic');
        var options = {canvas: true, maxWidth: $preview.width()};

        loadImage.parseMetaData(file, function (data) {
            if (data.exif) {
                options.orientation = data.exif.get('Orientation')
            }

            loadImage(
                file,
                function (img) {
                    $preview.html(img);
                    $('.campaigns__preview_content').scrollTo($preview, 300);
                },
                options
            )
        });
    });

    function parseVideo (url) {
        // - Supported YouTube URL formats:
        //   - http://www.youtube.com/watch?v=My2FRPA3Gf8
        //   - http://youtu.be/My2FRPA3Gf8
        //   - https://youtube.googleapis.com/v/My2FRPA3Gf8
        // - Supported Vimeo URL formats:
        //   - http://vimeo.com/25451551
        //   - http://player.vimeo.com/video/25451551
        // - Also supports relative URLs:
        //   - //player.vimeo.com/video/25451551
        // - DailyMotion
        //   - http://www.dailymotion.com/video/x6ga7eg

        url.match(/(http:|https:|)\/\/(player.|www.)?(vimeo\.com|youtu(be\.com|\.be|be\.googleapis\.com)|dailymotion.com)\/(video\/|embed\/|watch\?v=|v\/|channels\/[^/]*\/)?([A-Za-z0-9._%-]*)(\&\S+)?/);
        var type;
        var typeStr = RegExp.$3;
        var id = RegExp.$6;

        if (typeStr.indexOf('youtu') > -1) {
            type = 'youtube';
        } else if (typeStr.indexOf('vimeo') > -1) {
            type = 'vimeo';
            $.getJSON('https://vimeo.com/api/oembed.json?url=https%3A//vimeo.com/' + id, {
                    format: "json",
                    width: "320"
                },
                function(data) {
                    $('.video_thumb_url').val(data.thumbnail_url);
                });
        } else if (typeStr.indexOf('dailymotion') > -1) {
            type = 'dailymotion';
        }

        return {
            type: type,
            id: id
        };
    }

    function createVideo (videoObj, width, height) {
        // Returns an iframe of the video with the specified URL.
        var $iframe = $('<iframe>', { width: width, height: height });
        $iframe.attr('frameborder', 0);
        if (videoObj.type === 'youtube') {
            $iframe.attr('src', 'https://www.youtube.com/embed/' + videoObj.id);
        } else if (videoObj.type === 'vimeo') {
            $iframe.attr('src', 'https://player.vimeo.com/video/' + videoObj.id);
        } else if (videoObj.type === 'dailymotion') {
            $iframe.attr('src', 'https://www.dailymotion.com/embed/video/' + videoObj.id);
        }
        return $iframe;
    }

    $('#campaign_video_url').on('input', function() {
        var url;
        var html = '';
        if (this.value) {
            var videoObj = parseVideo(this.value);
            if (videoObj.type) {
                var iframe = createVideo(videoObj, 350, 200);
                html = iframe.get(0).outerHTML;
                $('#campaign_video_url').val(iframe.attr('src'));
            } else {
                html = '<video width="300" height="200"><source src="' + this.value + '"></video>';
            }
        }
        $("#offerVideo").html(html);
    });

    $('#campaign_offer_title').on('input', function() {
        $("#view_offer_title").html(this.value);
    });

    $('#announcement_title').on('input', function() {
        $("#view_offer_title").html(this.value);
    });

    // $('#offerDetailsRow').hide();
    // $('#campaign_details').on('input', function() {
    //     $('#offerDetailsRow').toggle(!!this.value);
    //     $("#offerDetailsText").html(this.value.replace(/\n/g,'<br/>'));
    // });

    $('#couponCode').hide();
    $('#campaign_coupon_code').on('input', function() {
        $('#couponCode').toggle(!!this.value);
        $("#view_coupon_code").html(this.value.toUpperCase());
    });

    $('#campaign_age').on('input', function() {
        $("#view_offer_age").html(this.value === "None" ? "All Ages" : "Must be age: " + this.value);
    });

    $('#campaign_restrictions').on('input', function() {
        $(".offer_restriction").html(this.value === 'None' ? 'No restrictions' : this.value);
    });

    // $('#campaignConditionsRow').hide();
    // $('#campaign_offer_condition').on('input', function() {
    //   console.log("Saving Offer Conditions");
    //     $('#campaignConditionsRow').toggle(!!this.value);
    //     $("#offerConditionsText").html(this.value.replace(/\n/g,'<br/>'));
    // });

    $('.fa-info').tooltip();

    function validateFields() {
        var disabled = false;
        $.each($("#new_campaign .item.active input:visible.required, #new_campaign .item.active select:visible.required"),
            function (index, value) {
                if(!$(value).val()){ disabled = true; }
            });
        var locations = $.makeArray($('.item.active .locations_input'));
        if (locations.length) {
            disabled = disabled || !locations.some(function(location) { return location.checked;}) ||
                (!$.makeArray($('.item.active .agents_input')).some(function(agent) { return agent.checked;}) &&
                    !$.makeArray($('.item.active .add_upcoming')).some(function(upcoming) { return upcoming.checked;})
                );
        }

        $('.next_button').attr("disabled", disabled);
    }

    $("#new_campaign input.required, #new_campaign select.required, .custom_action_checkbox")
        .on('input change dp.change', function () {
            setTimeout(validateFields, 400);
        });

    $('.next_button').attr("disabled", true);
    $('.prev_button').hide();
    $('.submit_button').hide();

    $('.prev_button').click(function() {
        $('.campaigns__preview_frame').hide();
        $('#campaign_carousel').carousel('prev');
        $('.next_button').show();
        $('.submit_button').hide();
    });

    $('.next_button').click(function() {
        $('.campaigns__preview_frame').hide();
        $('#campaign_carousel').carousel('next');
        $('.prev_button').show();
    });

    $('#campaign_carousel').on('slid.bs.carousel', function() {
        $('.carousel-item.active').each(function () {
            var step = $(this).data('step');
            $('#campaignTitle').html($(this).data('title'));

            $('.campaign_step').each(function () {
                var currentStep = $(this).data('step');
                $(this).toggleClass('selected', step >= currentStep);
            });
        });
        if($('.carousel-inner .carousel-item:first').hasClass('active')) {
            $('.prev_button').hide();
            $('.campaigns__preview_frame').show();
        }
        if($('.carousel-inner .carousel-item:last').hasClass('active')) {
            $('.next_button').hide();
            $('.submit_button').show();
            $('.campaigns__preview_frame').show();
        }
        validateFields();
    });

    var client_locations = {};
    $('employee_group').hide();
    $('friend_group').hide();

    var previous_location = '';

    $('.agents_input').each(function () {
        var id = $(this).val();
        var location = $(this).data('location');
        if (location) {
            var cl = client_locations[location] || [];
            cl.push(id);
            client_locations[location] = cl;
        }
        $(this).parents('.checkbox').hide();
        if (previous_location !== location) {
            var locationObj = $('.locations_input[value="' + location + '"]');
            var locationString = locationObj.first().data('name');
            $(this).parents('.checkbox')
                .before('<small class="agent_group help-block" data-location="' + location + '">' + locationString + '</small>');
            previous_location = location;
        }
    });
    $('.agent_group').hide();

    $('.select_all').change(function() {
        var checked = this.checked;
        $('.agents_input:visible').each(function () {
            $(this).prop("checked", checked).trigger('change');
        });
    });

    $('.locations_input').change(function () {
        var location = $(this).val();
        var checked = this.checked;
        $('#locationsRow').toggle($('.locations_input:checked').length === 1);

        $('.location-row[data-location="' + location + '"]').each(function() {
            $(this).toggle(checked);
        });

        var changed = client_locations[location];
        if (!changed) return;

        $('.agent_group[data-location="' + location + '"]').toggle(checked);

        $('.agents_input').each(function () {
            var agent = $(this).val();
            if(agent && changed.indexOf(agent) !== -1) {
                var selectAll = $('.select_all')[0].checked;
                $(this).parents('.checkbox').toggle(checked);
                if (!checked || selectAll) {
                    $(this).prop("checked", checked).trigger('change');
                }
            }
        });

    });

    $('.agents_input').change(function () {
        $('#campaign_coupons').trigger('change');
        var emplList = '';
        var friendList = '';
        $('.agents_input').each(function () {
            var checked = this.checked;
            if (checked) {
                var role = $(this).data('role');
                var item = '<li><span>' + $(this).parent().text() + '</span></li>';
                if (role === 'agent') {
                    emplList = emplList + item;
                }
                if (role === 'friend') {
                    friendList = friendList + item;
                }
            }
        });
        $('.employee_group').toggle(!!emplList);
        $('.friend_group').toggle(!!friendList);
        $('.employee_list').html('<ul>' + emplList + '</ul>');
        $('.friend_list').html('<ul>' + friendList + '</ul>');
    });

    $('.minus_button').click(function () {
        var fld = $('#campaign_coupons');
        var val = ~~fld.val() - 1;
        fld.val(val || 1);
        fld.trigger('change');
    });

    $('.plus_button').click(function () {
        var fld = $('#campaign_coupons');
        var val = ~~fld.val() + 1;
        fld.val(val);
        fld.trigger('change');
    });

    $('#campaign_coupons').change(function () {
        var fld = $(this);
        var val = ~~fld.val();
        fld.val(val);
        var checked = 0;
        $('.agents_input').each(function () {
            if (this.checked) checked++;
        });
        $('.agent_cnt').html(checked + 1);
        var coupon_count = val ? val * (checked+1) : 'Unlimited';
        $('.coupon_count').html(coupon_count);
        $('.num_agents').val(checked);
        $('.num_coupons').val(val);
        var num_coupons_txt = val ? String(val) + ' each' : 'Unlimited';
        $('.num_coupons_txt').html(num_coupons_txt);
    });

    $('#campaign_coupons').trigger('change');

    $('.add_upcoming').change(function () {
       $('.add_upcoming_val').val(this.checked ? 'true' : 'false');
    });

    $('.location-row').each(function() {
        $(this).hide();
    });

/*    $('.custom_action_checkbox').change(function () {
        var checked = this.checked;
        $('.cta_custom').each(function() {
            $(this).toggle(checked);
        });
        if (!checked) {
            $('.cta_input, .redirect_input').val(null);
            $('.cta_input').trigger('change');
            $('.redirect_input').trigger('input');
        }
    });*/

    $('.limited_coupons').change(function () {
        var checked = this.checked;
        $('.coupon_wrapper').each(function() {
            $(this).toggle(checked);
        });
        var defaultCoupons  = checked ? 3 : null;
        $('.coupon_num').each(function() {
            $(this).val(defaultCoupons);
            $(this).trigger('change');
        });
    });

    $('.coupon_wrapper').hide();

    $('.cta_input').on('input', function () {
      var cta = $(this).val();
      $('.cta_text').val(cta);
      $('.redeem-button').html(cta);
    });

    $('.campaign_cta .scombobox-display').on('input', function() {
        var value = $(this).val();
        $('.cta_text').val(value);
        $('.redeem-button').html(value);
    });

    $('.redirect_input').on('input', function () {
        var value = $(this).val();
        var cta = $('.cta_text').val();
        if (cta) {
            if (value && !value.match(/^http/i)) value = 'http://' + value;
            $("#previewForm").attr("action", value);
        }
    });

    $("#previewForm").on('submit', function () {
        return !!$(this).attr("action");
    });

    function onDateRangeChanged(start, end) {
        var runDate = end.format("L");
        $('.run_date').val(end.format('MM/DD/YYYY h:mm A'));
        if (start) {
            $('.start_date').val(start.format('MM/DD/YYYY h:mm A'));
            var startText = start.format("L");
            if (startText !== runDate) {
                runDate = start.format("L") + ' - ' + runDate;
            }
        }
        $(".view_run_date").html(runDate);
    }

    $('.daterange').daterangepicker({
        "autoApply": true,
        "linkedCalendars": false,
        minDate: moment().format('L'),
        locale: {
            format: 'MM/DD/YYYY'
        }
    }, onDateRangeChanged);
    var data = $('.daterange').data('daterangepicker');
    if (data) onDateRangeChanged(null, data.endDate);

    var credentials = {
        action: 'userCreated',
        username: $('#finish-express__username').val(),
        password: $('#finish-express__password').val()
    };
    if (credentials.username && credentials.password) {
        parent.postMessage(credentials, "https://justspeakeasy.com");
    }

    $("#campaign_create").on('click', function () {
        window.location = $("#campaign_create").data('location');
    });

    $('#locationsRestricted').modal();

    $("#new_location_cancel").on('click', function () {
        window.location = $("#new_location_cancel").data('location');
    });

    $("#new_location_create").on('click', function () {
        window.location = $("#new_location_create").data('location');
    });

    $('#new_campaign').on('keyup keypress', function(e) {
        var keyCode = e.keyCode || e.which;
        if (keyCode === 13) {
            e.preventDefault();
            return false;
        }
    });

    var campaignConfirmed = false;

    $("#new_campaign").on('submit', function (e) {
        if (campaignConfirmed) return true;

        $('#confirmSendCampaign').modal();
        e.preventDefault();
        return false;
    });

    $("#sendConfirmed").on('click', function () {
        campaignConfirmed = true;
        $("#new_campaign").trigger('submit');
    });

    var csvImport = [];

    $("#csv-file").on('change', function (evt) {
        var file = evt.target.files[0];
        var re = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
        var fields = ['firstname', 'lastname', 'email'];
        $('.csv_errors').hide();

        Papa.parse(file, {
            header: true,
            skipEmptyLines: true,
            complete: function(results) {
                var data = results.data;
                var errors = [];

                data.map(function (row, idx) {
                    fields.map(function(fld) {
                        if (!row[fld]) {
                            var err = fld + ' is empty in a row ' + (idx + 1);
                            errors.push(err);
                        }
                    });
                    if (row.email && !re.test(row.email)) {
                        var err = 'Email ' + row.email +' is wrong in a row ' + (idx + 1);
                        errors.push(err);
                    }
                });

                if (!errors.length) {
                    csvImport = data;
                    $('.csv_import').val(JSON.stringify(csvImport));
                } else {
                    $('.csv_errors_text')
                        .html('CSV file has errors!')
                        .tooltip({title: errors.join("\n")});
                    $('.csv_errors').show();
                    csvImport = [];
                }
                validateImportForm();
            }
        });
    });

    function validateImportForm() {
        var hasEmpty = $('#user_role, #user_location_id')
            .children(':selected')
            .filter(function() {
                return $(this).text() === '';
            }).size();

        $('#importCsv').attr("disabled", hasEmpty || !csvImport.length);

    }

    $('#user_role, #user_location_id').on('change', validateImportForm);

    $('#importCsv').attr("disabled", true);
    $('.csv_errors').hide();

    $('.csv-import-form').on('submit', function() {
        $('#importCsv')
            .attr("disabled", true)
            .button('loading');
        return true;
    })

    $('#campaign_attachment').on('input', function () {
        var type = $(this).val();
        var tooltip = $(this).children(':selected').data("tooltip");
        var showImage = type === 'image';
        $('.campaign_photo').toggle(showImage);
        $('.campaign_video_url').toggle(!showImage);
        $('#attachment_tooltip').attr("data-original-title", tooltip);
        $('#offerPic').toggle(showImage);
        $("#offerVideo").toggle(!showImage);
        var inputToReset = showImage ? $('#campaign_video_url') : $('#campaign_photo');
        var previewToReset = showImage ? $('#offerVideo') : $('#offerPic');
        inputToReset.val('');
        previewToReset.html('');
    });

    $('#campaign_attachment').trigger('input');


    /*
        var elements = $('#redeemButtonBlock');
        Stickyfill.add(elements);*/

    $.each(flashMessages, function(key, value){
        $.snackbar({content: value, style: key, timeout: 5000});
    });
});

var expanded = false;

function showCheckboxes() {
var checkboxes = document.getElementById("checkboxes");
if (!expanded) {
    checkboxes.style.display = "block";
    expanded = true;
} else {
    checkboxes.style.display = "none";
    expanded = false;
}
}

var locations = new Array();
function checkLoc(checkbox) {
if (checkbox.checked) {
    locations.push(checkbox.id);
} else {
    locations = locations.filter(function(item) {
        return item !== checkbox.id
    })
}
var locObject = document.getElementById("announcement_locations");
locObject.value = locations;
}
