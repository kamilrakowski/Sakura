<a href="/news/{{ newsPost.id }}" class="news-head" id="{{ newsPost.id }}">{{ newsPost.title }}</a>
<div class="news-body">
    <a class="default" href="/u/{{ newsPost.uid }}">
        <div class="news-poster">
            <img src="/a/{{ newsPost.uid }}" alt="{{ users[newsPost.uid].username }}" class="default-avatar-setting" />
            <h1 style="color: #{{ group[users[newsPost.uid].group_main].colour }} !important; text-shadow: 0 0 7px #888; padding: 0 0 10px;">{{ users[newsPost.uid].username }}</h1>
        </div>
    </a>
    <div class="markdown">
        {{ newsPost.content }}
    </div>
</div>
<div class="clear"></div>
<div class="news-post-time">
    Posted on {{ newsPost.date|date("D Y-m-d H:i:s T") }} <a class="default" href="/news/{{ newsPost.id }}#disqus_thread">View comments</a>
</div>