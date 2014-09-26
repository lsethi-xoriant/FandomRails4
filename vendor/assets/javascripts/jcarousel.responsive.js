(function($) {
    $(function() {
        var jcarousel = $('.jcarousel');

        jcarousel
            .on('jcarousel:reload jcarousel:create', function () {
                var width = jcarousel.innerWidth();

                if (width >= 600) {
                    width = width / 4;

                    jcarousel.jcarouselAutoscroll({
                        interval: 3000,
                        target: '+=4',
                        autostart: true
                    });

                } else if (width >= 350) {
                    width = width / 1;

                    jcarousel.jcarouselAutoscroll({
                        interval: 3000,
                        target: '+=1',
                        autostart: true
                    });

                }

                jcarousel.jcarousel('items').css('width', width + 'px');
            })
            .jcarousel({
                wrap: 'circular'
            });
            
        $('.jcarousel-control-prev')
            .jcarouselControl({
                target: '-=4'
            });

        $('.jcarousel-control-next')
            .jcarouselControl({
                target: '+=4'
            });

        $('.jcarousel-control-prev.mobile')
            .jcarouselControl({
                target: '-=1'
            });

        $('.jcarousel-control-next.mobile')
            .jcarouselControl({
                target: '+=1'
            });

        $('.jcarousel-pagination')
            .on('jcarouselpagination:active', 'a', function() {
                $(this).addClass('active');
            })
            .on('jcarouselpagination:inactive', 'a', function() {
                $(this).removeClass('active');
            })
            .on('click', function(e) {
                e.preventDefault();
            })
            .jcarouselPagination({
                perPage: 4,
                item: function(page) {
                    return '<a href="#' + page + '">' + page + '</a>';
                }
            });

        $('.jcarousel-pagination.mobile')
            .on('jcarouselpagination:active', 'a', function() {
                $(this).addClass('active');
            })
            .on('jcarouselpagination:inactive', 'a', function() {
                $(this).removeClass('active');
            })
            .on('click', function(e) {
                e.preventDefault();
            })
            .jcarouselPagination({
                perPage: 1,
                item: function(page) {
                    return '<a href="#' + page + '">' + page + '</a>';
                }
            });

    });
})(jQuery);
