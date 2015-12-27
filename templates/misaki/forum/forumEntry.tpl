<div class="forumSubEntry">
    <a href="{% if forum.forum_type == 2 %}{{ forum.forum_link }}{% else %}{{ urls.format('FORUM_SUB', [forum.forum_id]) }}{% endif %}" class="forumSubIcon">
        <div class="forumIcon fa fa-3x {% if forum.icon %}{{ forum.icon }}{% else %}{% if forum.type == 2 %}fa-chevron-circle-right{% elseif forum.type == 1 %}fa-folder{% else %}fa-comments{% endif %}{% endif %}"></div>
    </a>
    <div class="forumSubTitle">
        <a href="{% if forum.type == 2 %}{{ forum.link }}{% else %}{{ urls.format('FORUM_SUB', [forum.id]) }}{% endif %}" class="forumSubName">{{ forum.name }}</a>
        <div class="forumSubDesc">
            {{ forum.description }}
            {% if forum.forums|length %}
                <ul class="forumSubSubforums">
                    {% for forum in forum.forums %}
                        <li><a href="{% if forum.type == 2 %}{{ forum.link }}{% else %}{{ urls.format('FORUM_SUB', [forum.id]) }}{% endif %}" class="default"><span class="fa {% if forum.icon %}{{ forum.icon }}{% else %}fa-bars{% endif %}"></span> {{ forum.name }}</a></li>
                    {% endfor %}
                </ul>
            {% endif %}
        </div>
    </div>
    {% if forum.forum_type != 2 %}
    <div class="forumSubStats">
        <div class="forumSubTopics" title="Amount of threads in this forum.">{{ forum.threadCount }}</div>
        <div class="forumSubStatsSeperator">/</div>
        <div class="forumSubPosts" title="Amount of posts in this forum.">{{ forum.postCount }}</div>
    </div>
    <div class="forumSubReplies">
        <div>
            {% if forum.lastPost.id %}
                <a href="{{ urls.format('FORUM_THREAD', [forum.lastPost.thread]) }}" class="default">{{ forum.lastPost.subject|slice(0, 25) }}{% if forum.lastPost.subject|length > 25 %}...{% endif %}</a><br />
                <span title="{{ forum.lastPost.time|date(sakura.dateFormat) }}">{{ forum.lastPost.timeElapsed }}</span> by {% if forum.lastPost.poster.id %}<a href="{{ urls.format('USER_PROFILE', [forum.lastPost.poster.id]) }}" class="default" style="color: {{ forum.lastPost.poster.colour }}; text-shadow: 0 0 5px {% if forum.lastPost.poster.colour != 'inherit' %}{{ forum.lastPost.poster.colour }}{% else %}#222{% endif %};">{{ forum.lastPost.poster.username }}</a>{% else %}[deleted user]{% endif %} <a href="{{ urls.format('FORUM_POST', [forum.lastPost.id]) }}#p{{ forum.lastPost.id }}" class="default fa fa-tag"></a>
            {% else %}
                There are no posts in this forum.
            {% endif %}
        </div>
    </div>
    {% endif %}
</div>
