// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
$().ready(function () {
    var form;
    var $business = $('.business');

    if ($business.length > 0) {
        form = $('.business-form');

        form.formValidation({
            framework: 'bootstrap',
            fields: {
                'business[business_phone]': {
                    validators: {
                        callback: {
                            message: 'The phone number is not valid',
                            callback: function(value, validator, $field) {
                                return value === '' || $field.intlTelInput('isValidNumber');
                            }
                        }
                    }
                }
            }
        });

        form.submit(function () {
            $('input[type="tel"]').each(function () {
               if ($(this).val() != '') {
                   var formatted = $(this).intlTelInput("getNumber");
                   $(this).val(formatted);
               }
            });
        });
    }

    try {
      var canvas = $("#businessCanvas");
      var context = canvas.get(0).getContext("2d");
      var logoPic = $("#inviteBusinessLogo");
      form = $('.business-form');

      $("#businessFileInput").on("change", function() {
        if (this.files && this.files[0]) {
          if (this.files[0].type.match(/^image\//)) {
            var reader = new FileReader();
            reader.onload = function(evt) {
              var img = new Image();
              img.onload = function() {
                context.canvas.width = img.width;
                context.canvas.height = img.height;
                context.drawImage(img, 0, 0);
                canvas.cropper("destroy");
                var cropper = canvas.cropper({
                  aspectRatio: 1 / 1,
                  autoCropArea: 0.8,
                  restore: true,
                  guides: true,
                  center: true,
                  highlight: true,
                  cropBoxMovable: true,
                  cropBoxResizable: false,
                  toggleDragModeOnDblclick: false,
                  movable: false,
                  zoomable: true,
                  rotatable: false,
                  scalable: true
                });
              };
              img.src = evt.target.result;
            };
            reader.readAsDataURL(this.files[0]);
          }
        }
      });

      $("#uploadBusinessConfirm").click(function() {
        var croppedUrl = canvas
          .cropper("getCroppedCanvas")
          .toDataURL("image/png");
        if (croppedUrl != null) {
          form.append(
            $(`<input type="hidden" id="cropped-photo" name="new_logo_photo" value=${croppedUrl} />`)
          );
          logoPic.empty();
          logoPic.append(
            $("<img class='business-logo'>").attr("src", croppedUrl)
          );
        }
      });
    } catch (error) {}
});
