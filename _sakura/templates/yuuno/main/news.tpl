{% include 'global/header.tpl' %}
    <div class="content">
        <div class="content-column news">
            <div class="head">News <a href="/news.xml" class="fa fa-rss news-rss default"></a></div>
            {% for newsPost in newsPosts %}
                {% include 'elements/newsPost.tpl' %}
            {% endfor %}
        </div>
    </div>
    <script type="text/javascript">
        /* * * CONFIGURATION VARIABLES: EDIT BEFORE PASTING INTO YOUR WEBPAGE * * */
        var disqus_shortname = 'flashii';

        /* * * DO NOT EDIT BELOW THIS LINE * * */
        (function () {
            var s = document.createElement('script'); s.async = true;
            s.type = 'text/javascript';
            s.src = '//' + disqus_shortname + '.disqus.com/count.js';
            (document.getElementsByTagName('HEAD')[0] || document.getElementsByTagName('BODY')[0]).appendChild(s);
        }());
    </script>
{% include 'global/footer.tpl' %}