// JQuery for Offer ~ Campaign page
//= require jquery-cropper.js
//= require cropper.js
$().ready(function() {
  var totals = {};
  var teamMemberList = $(".team-member-list");
  const startRow = '<div class="row" style="margin-bottom: 10px;">';
  const endDiv = "</div>";
  const locationCol = '<div class="col-8">';
  const totalCol = '<div class="col-4 float-right" style="width: 100%;">';

  try {
    var canvas = $("#canvas");
    var context = canvas.get(0).getContext("2d");
    var form = $("#new_campaign");
    var offerPic = $("#offerPic");

    $("#fileInput").on("change", function() {
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
                autoCropArea: 0.7,
                restore: true,
                guides: true,
                center: true,
                highlight: true,
                cropBoxMovable: true,
                cropBoxResizable: true,
                toggleDragModeOnDblclick: false,
                movable: true,
                zoomable: true,
                rotatable: false,
                scalable: false,
                minContainerWidth: 350,
                minCropBoxWidth: 300
              });
            };
            img.src = evt.target.result;
          };
          reader.readAsDataURL(this.files[0]);
        }
      }
    });
  } catch (error) {}

  selectAllHQ = function(checked){
    if(checked){
      $(".send_owner").prop("checked", true);
      totals['Headquarters'] = $(".send_owner").length;;
      teamMemberList.empty();
      var totalEmp = 0;
      for (var location in totals) {
        if (totals[location] > 0) {
          totalEmp = totalEmp + totals[location];
          teamMemberList.append(
            startRow +
              locationCol +
              '<h6 style="padding-left: 25px;">' +
              location +
              "</h6>" +
              endDiv +
              totalCol +
              '<h6 class="float-right" style="padding-right: 50px;">' +
              totals[location] +
              "</h6>" +
              endDiv +
              endDiv
          );
        }
      }
      if (totalEmp > 0) {
        teamMemberList.append(
          startRow +
            '<div class="col-12 float-right" style="width: 100%">' +
            '<h6 class="float-right" style="padding-right: 50px; padding-left: 50px; padding-top: 15px; border-top: 1px solid black; ">' +
            totalEmp +
            "</h6>" +
            endDiv +
            endDiv
        );
      }
    }
    else{
      $(".send_owner").prop("checked", false);
      totals['Headquarters'] = 0;
      teamMemberList.empty();
      var totalEmp = 0;
      for (var location in totals) {
        if (totals[location] > 0) {
          totalEmp = totalEmp + totals[location];
          teamMemberList.append(
            startRow +
              locationCol +
              '<h6 style="padding-left: 25px;">' +
              location +
              "</h6>" +
              endDiv +
              totalCol +
              '<h6 class="float-right" style="padding-right: 50px;">' +
              totals[location] +
              "</h6>" +
              endDiv +
              endDiv
          );
        }
      }
      if (totalEmp > 0) {
        teamMemberList.append(
          startRow +
            '<div class="col-12 float-right" style="width: 100%">' +
            '<h6 class="float-right" style="padding-right: 50px; padding-left: 50px; padding-top: 15px; border-top: 1px solid black; ">' +
            totalEmp +
            "</h6>" +
            endDiv +
            endDiv
        );
      }
    }
  }

  selectAll = function(checked, id, location) {

    if (checked) {
      $(".agentcheck-" + id).prop("checked", true);
      totals[location] = $(".agentcheck-" + id).length;
      teamMemberList.empty();
      var totalEmp = 0;
      for (var location in totals) {
        if (totals[location] > 0) {
          totalEmp = totalEmp + totals[location];
          teamMemberList.append(
            startRow +
              locationCol +
              '<h6 style="padding-left: 25px;">' +
              location +
              "</h6>" +
              endDiv +
              totalCol +
              '<h6 class="float-right" style="padding-right: 50px;">' +
              totals[location] +
              "</h6>" +
              endDiv +
              endDiv
          );
        }
      }
      if (totalEmp > 0) {
        teamMemberList.append(
          startRow +
            '<div class="col-12 float-right" style="width: 100%">' +
            '<h6 class="float-right" style="padding-right: 50px; padding-left: 50px; padding-top: 15px; border-top: 1px solid black; ">' +
            totalEmp +
            "</h6>" +
            endDiv +
            endDiv
        );
      }
    } else {
      $(".agentcheck-" + id).prop("checked", false);
      totals[location] = 0;
      teamMemberList.empty();
      var totalEmp = 0;
      for (var location in totals) {
        if (totals[location] > 0) {
          totalEmp = totalEmp + totals[location];
          teamMemberList.append(
            startRow +
              locationCol +
              '<h6 style="padding-left: 25px;">' +
              location +
              "</h6>" +
              endDiv +
              totalCol +
              '<h6 class="float-right" style="padding-right: 50px;">' +
              totals[location] +
              "</h6>" +
              endDiv +
              endDiv
          );
        }
      }
      if (totalEmp > 0) {
        teamMemberList.append(
          startRow +
            '<div class="col-12 float-right" style="width: 100%">' +
            '<h6 class="float-right" style="padding-right: 50px; padding-left: 50px; padding-top: 15px; border-top: 1px solid black; ">' +
            totalEmp +
            "</h6>" +
            endDiv +
            endDiv
        );
      }
    }
  };

  checkboxChanged = function(checked, location) {
    if (location in totals) {
      var previousValue = totals[location];
      if (checked) {
        totals[location] = previousValue + 1;
      } else {
        totals[location] = previousValue - 1;
      }
      teamMemberList.empty();
      var totalEmp = 0;
      for (var location in totals) {
        if (totals[location] > 0) {
          totalEmp = totalEmp + totals[location];
          teamMemberList.append(
            startRow +
              locationCol +
              '<h6 style="padding-left: 25px;">' +
              location +
              "</h6>" +
              endDiv +
              totalCol +
              '<h6 class="float-right" style="padding-right: 50px;">' +
              totals[location] +
              "</h6>" +
              endDiv +
              endDiv
          );
        }
      }
      if (totalEmp > 0) {
        teamMemberList.append(
          startRow +
            '<div class="col-12 float-right" style="width: 100%">' +
            '<h6 class="float-right" style="padding-right: 50px; padding-left: 50px; padding-top: 15px; border-top: 1px solid black; ">' +
            totalEmp +
            "</h6>" +
            endDiv +
            endDiv
        );
      }
    } else {
      if (checked) {
        totals[location] = 1;

        teamMemberList.empty();
        var totalEmp = 0;
        for (var location in totals) {
          if (totals[location] > 0) {
            totalEmp = totalEmp + totals[location];
            teamMemberList.append(
              startRow +
                locationCol +
                '<h6 style="padding-left: 25px;">' +
                location +
                "</h6>" +
                endDiv +
                totalCol +
                '<h6 class="float-right" style="padding-right: 50px;">' +
                totals[location] +
                "</h6>" +
                endDiv +
                endDiv
            );
          }
        }
        if (totalEmp > 0) {
          teamMemberList.append(
            startRow +
              '<div class="col-12 float-right" style="width: 100%">' +
              '<h6 class="float-right" style="padding-right: 50px; padding-left: 50px; padding-top: 15px; border-top: 1px solid black; ">' +
              totalEmp +
              "</h6>" +
              endDiv +
              endDiv
          );
        }
      } else {
        totals[location] = 0;

        teamMemberList.empty();
        var totalEmp = 0;
        for (var location in totals) {
          if (totals[location] > 0) {
            totalEmp = totalEmp + totals[location];
            teamMemberList.append(
              startRow +
                locationCol +
                '<h6 style="padding-left: 25px;">' +
                location +
                "</h6>" +
                endDiv +
                totalCol +
                '<h6 class="float-right" style="padding-right: 50px;">' +
                totals[location] +
                "</h6>" +
                endDiv +
                endDiv
            );
          }
        }
        if (totalEmp > 0) {
          teamMemberList.append(
            startRow +
              '<div class="col-12 float-right" style="width: 100%">' +
              '<h6 class="float-right" style="padding-right: 50px; padding-left: 50px; padding-top: 15px; border-top: 1px solid black; ">' +
              totalEmp +
              "</h6>" +
              endDiv +
              endDiv
          );
        }
      }
    }
  };

  $("#uploadConfirm").click(function() {
    var croppedUrl = canvas.cropper("getCroppedCanvas").toDataURL("image/png");
    if (croppedUrl != null) {
      form.append(
        $(`<input type="hidden" name="cropped_photo" value=${croppedUrl} />`)
      );
      offerPic.empty();
      offerPic.append($("<img>").attr("src", croppedUrl));
    }
  });

  $("#uploadConfirmAnn").click(function() {
    var croppedUrl = canvas.cropper("getCroppedCanvas").toDataURL("image/png");
    if (croppedUrl != null) {
      var annForm = $("#new_announcement");
      annForm.append(
        $(`<input type="hidden" name="cropped_photo" value=${croppedUrl} />`)
      );
      offerPic.empty();
      offerPic.append($("<img>").attr("src", croppedUrl));
    }
  });

  $("#cancelCampaign").click(function() {
    console.log("ID: ", $("#object_id").data("source"));
    $.ajax({
      url: "/ajax/cancel_campaign",
      type: "POST",
      data: JSON.stringify({ object_id: $("#object_id").data("source") }),
      dataType: "json",
      contentType: "application/json"
    }).done(function() {
      window.top.location.reload(true);
    });
  });
});
