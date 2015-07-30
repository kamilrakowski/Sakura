{% include 'global/header.tpl' %}
    <div class="content homepage">
        <div class="content-right content-column">
            {% include 'elements/indexPanel.tpl' %}
        </div>
        <div class="content-left content-column">
            <div class="head">News <a href="/news.xml" class="fa fa-rss news-rss default"></a></div>
            {% for newsPost in newsPosts %}
                {% include 'elements/newsPost.tpl' %}
            {% endfor %}
        </div>
        <div class="clear"></div>
    </div>
    <script type="text/javascript" src="{{ sakura.resources }}/js/ybabstat.js"></script>
    <script type="text/javascript">
        var disqus_shortname = 'flashii';

        (function () {
            var s = document.createElement('script');
            s.async = true;
            s.type = 'text/javascript';
            s.src = '//' + disqus_shortname + '.disqus.com/count.js';
            (document.getElementsByTagName('HEAD')[0] || document.getElementsByTagName('BODY')[0]).appendChild(s);
        }());
    </script>
{% include 'global/footer.tpl' %}
