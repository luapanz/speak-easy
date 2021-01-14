$().ready(function() {
  try {
    console.log("Checking Mobile");
    if (window.innerWidth <= 800) {
      $(".enroll-desktop-view").hide();
      $(".enroll-mobile-view").show();
    } else {
      $(".enroll-desktop-view").show();
      $(".enroll-mobile-view").hide();
    }
    window.on("load", () => {
      console.log("Page Loaded!");
    });
  } catch (e) {
    console.log("Enroll Error: " + e);
  }

  $(".agents-submit")
    .unbind("click")
    .click(function() {
      var phoneNumber = $("#enroll-phone").val();
      var locationId = $("#lid").val();
      var businessId = $("#bid").val();
      var terms = false;
      var error = $("#enroll-error");
      var success = $("#enroll-success");
      if ($(".terms").is(":checked")) {
        terms = true;
      }

      if (terms) {
        if (
          phoneNumber.length === 10 &&
          locationId.length === 10 &&
          businessId.length === 10
        ) {
          $.ajax({
            url: "/ajax/send_team_sms",
            type: "POST",
            data: JSON.stringify({
              phoneNumber: phoneNumber,
              businessId: businessId,
              locationId: locationId
            }),
            dataType: "json",
            contentType: "application/json"
          });
          error.hide();
          success.text("Text Message Sent!");
          success.show();
        } else {
          if (phoneNumber.lenth !== 10) {
            error.text(
              "Must enter a valid phone number. Only use numbers. Phone Number must be 10 digits."
            );
            error.show();
          } else {
            error.text("Sorry. Something went wrong.");
            error.show();
          }
        }
      } else {
        error.text("Must Accept Terms");
        error.show();
      }
    });
});
