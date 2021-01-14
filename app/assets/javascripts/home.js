// JQuery for Home page
// Handles the tutorial cards
$().ready(function() {
  // Click on App Card
  $(".tutorial_card_app").click(function() {
    $.ajax({
      url: "/ajax/tutorial_app",
      type: "POST",
      data: JSON.stringify({ business_id: $("#tutorial_biz").data("source") }),
      dataType: "json",
      contentType: "application/json"
    });
  });
  // Refresh after modal close
  $("#tutorialAppModal").on("hidden.bs.modal", function() {
    window.top.location.reload(true);
  });

  // Click on Team Card
  $(".tutorial_card_team").click(function() {
    $.ajax({
      url: "/ajax/tutorial_team",
      type: "POST",
      data: JSON.stringify({ business_id: $("#tutorial_biz").data("source") }),
      dataType: "json",
      contentType: "application/json"
    });
  });
  // Refresh after modal close
  $("#tutorialTeamModal").on("hidden.bs.modal", function() {
    window.top.location.reload(true);
  });

  // Click on Fans Card
  $(".tutorial_card_fans").click(function() {
    $.ajax({
      url: "/ajax/tutorial_fans",
      type: "POST",
      data: JSON.stringify({ business_id: $("#tutorial_biz").data("source") }),
      dataType: "json",
      contentType: "application/json"
    });
  });
  // Refresh after modal close
  $("#tutorialFanModal").on("hidden.bs.modal", function() {
    window.top.location.reload(true);
  });

  // Click on Location Card
  $(".tutorial_card_location").click(function() {
    $.ajax({
      url: "/ajax/tutorial_location",
      type: "POST",
      data: JSON.stringify({ business_id: $("#tutorial_biz").data("source") }),
      dataType: "json",
      contentType: "application/json"
    });
  });

  // Click on Business Card
  $(".tutorial_card_business").click(function() {
    $.ajax({
      url: "/ajax/tutorial_business",
      type: "POST",
      data: JSON.stringify({ business_id: $("#tutorial_biz").data("source") }),
      dataType: "json",
      contentType: "application/json"
    });
  });
});

window.checkMobileNum = function(num) {
  var phoneNumber = num;
  if (phoneNumber.length == 10) {
    // SEND SMS
    console.log("About to send");
    $.ajax({
      url: "/ajax/send_sms",
      type: "POST",
      data: JSON.stringify({ number: phoneNumber}),
      dataType: "json",
      contentType: "application/json"
    });
    return 1;
  } else {
    return 0;
  }
};
