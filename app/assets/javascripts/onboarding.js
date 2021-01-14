$().ready(function () {
    var switchFooters = function() {
        if($('.carousel-inner .item:last').hasClass('active')) {
            $('.bottom-navigation').hide();
            $('.top-navigation').hide();
            $('.site-footer').show();
        }
        else {
            $('.site-footer').hide();
        }
    };
    $('#onboardingCarousel').on('slid.bs.carousel', switchFooters);
    switchFooters();

    $("#welcomeDialogButton").click(function() {
        $("#campaignDialog").modal('show');
    });
    $("#campaignDialogButton").click(function() {
        $("#teamMembersDialog").modal('show');
    });
    $("#teamMembersDialogButton").click(function() {
        $("#getStartedDialog").modal('show');
    });
    
});
