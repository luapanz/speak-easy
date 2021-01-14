$().ready(function() {
  $(".phone-radio").toggle(false);
  $(".phone-label").toggle(false);

  $("#emailRadio").change(function() {
    $(".email-radio").toggle(true);
    $(".email-label").toggle(true);
    $(".phone-radio").toggle(false);
    $(".phone-label").toggle(false);
  });

  $("#textRadio").change(function() {
    $(".email-radio").toggle(false);
    $(".email-label").toggle(false);
    $(".phone-radio").toggle(true);
    $(".phone-label").toggle(true);
  });

  try {
    var canvas = $("#inviteCanvas");
    var context = canvas.get(0).getContext("2d");
    var form = $("#new_invite");
    var logoPic = $("#inviteBusinessLogo");
    var inputLink = $("#share-link");
    var expiration = $("#enrollexpire");
    var copyButton = $("#enroll-copy");
    var businessLogo = $("#business-url").val();

    $("#inviteFileInput").on("change", function() {
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
                aspectRatio: 16 / 9,
                autoCropArea: 0.5,
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

    $("#expire-select").change(function() {
      var selected = $(this)
        .children(":selected")
        .val();
      expiration.val(selected);
    });

    $(".enroll-location").change(function() {
      var id = $(".enroll-location").val();
      if(id !==null && id !== ""){
        var url = $("#" + id).val();
        if (url !== null && url !== "") {
          logoPic.empty();
          logoPic.append(
            $("<img class='agents-business-logo'>").attr("src", url)
          );
          $('#cropped-photo').remove();
          $('#upload-photo-button').prop('disabled', false);
        } else {
          logoPic.empty();
          logoPic.append(
            $("<img class='agents-business-logo'>").attr("src", businessLogo)
          );
          $('#cropped-photo').remove();
          $('#upload-photo-button').prop('disabled', false);
        }
      }
      else{
        logoPic.empty();
        logoPic.append(
          $("<img class='agents-business-logo'>").attr("src", businessLogo)
        );
        $('#cropped-photo').remove();
        $('#upload-photo-button').prop('disabled', true);
      }
    });

    copyButton.click(function() {
      var link = inputLink.val();
      inputLink.select();
      document.execCommand("copy");
    });

    $("#uploadInviteConfirm").click(function() {
      var croppedUrl = canvas
        .cropper("getCroppedCanvas")
        .toDataURL("image/png");
      if (croppedUrl != null) {
        form.append(
          $(`<input type="hidden" id="cropped-photo" name="new_logo_photo" value=${croppedUrl} />`)
        );
        logoPic.empty();
        logoPic.append(
          $("<img class='agents-business-logo'>").attr("src", croppedUrl)
        );
      }
    });

    form
      .on("ajax:success", function(e, data) {
        inputLink.val(
          "http://account.justspeakeasy.com/enroll/" + data.objectId
        );
      })
      .on("ajax:error", function(e, xhr, status, error) {
        console.log("Error: " + error);
      });
  } catch (error) {}
});
