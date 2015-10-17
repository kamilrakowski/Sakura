<!DOCTYPE html>
<html>
    <head>
        <!-- META -->
        <meta charset="{{ sakura.charset }}" />
        <title>{% block title %}{{ sakura.siteName }}{% endblock %}</title>
        <meta name="description" content="{{ sakura.siteDesc }}" />
        <meta name="keywords" content="{{ sakura.siteTags }}" />
        <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no" />
        <meta name="msapplication-TileColor" content="#9475b2" />
        <meta name="msapplication-TileImage" content="/content/images/icons/ms-icon-144x144.png" />
        <meta name="theme-color" content="#9475B2" />
{% if page.redirect %}
        <meta http-equiv="refresh" content="{{ page.redirectTimeout ? page.redirectTimeout : '3' }}; URL={{ page.redirect }}" />
{% endif %}
        <link rel="apple-touch-icon" sizes="57x57" href="/content/images/icons/apple-icon-57x57.png" />
        <link rel="apple-touch-icon" sizes="60x60" href="/content/images/icons/apple-icon-60x60.png" />
        <link rel="apple-touch-icon" sizes="72x72" href="/content/images/icons/apple-icon-72x72.png" />
        <link rel="apple-touch-icon" sizes="76x76" href="/content/images/icons/apple-icon-76x76.png" />
        <link rel="apple-touch-icon" sizes="114x114" href="/content/images/icons/apple-icon-114x114.png" />
        <link rel="apple-touch-icon" sizes="120x120" href="/content/images/icons/apple-icon-120x120.png" />
        <link rel="apple-touch-icon" sizes="144x144" href="/content/images/icons/apple-icon-144x144.png" />
        <link rel="apple-touch-icon" sizes="152x152" href="/content/images/icons/apple-icon-152x152.png" />
        <link rel="apple-touch-icon" sizes="180x180" href="/content/images/icons/apple-icon-180x180.png" />
        <link rel="icon" type="image/png" sizes="192x192"  href="/content/images/icons/android-icon-192x192.png" />
        <link rel="icon" type="image/png" sizes="32x32" href="/content/images/icons/favicon-32x32.png" />
        <link rel="icon" type="image/png" sizes="96x96" href="/content/images/icons/favicon-96x96.png" />
        <link rel="icon" type="image/png" sizes="16x16" href="/content/images/icons/favicon-16x16.png" />
        <link rel="manifest" href="/manifest.json" />
{{ block('meta') }}
        <!-- CSS -->
        <link rel="stylesheet" type="text/css" href="{{ sakura.resources }}/css/yuuno.css" />
{{ block('css') }}
        <!-- JS -->
        <script type="text/javascript" src="{{ sakura.resources }}/js/yuuno.js"></script>
        <script type="text/javascript">

            // Create an object so we can access certain settings from remote JavaScript files
            var sakuraVars = {

                "cookie": {

                    "prefix":   "{{ sakura.cookie.prefix }}",
                    "domain":   "{{ sakura.cookie.domain }}",
                    "path":     "{{ sakura.cookie.path }}"

                },

                "siteName":         "{{ sakura.siteName }}",
                "urlMain":          "{{ sakura.urlMain }}",
                "content":          "{{ sakura.contentPath }}",
                "resources":        "{{ sakura.resources }}",
                "recaptchaEnabled": "{{ sakura.recaptchaEnabled }}",

                "minUserLen":       {{ sakura.minUsernameLength }},
                "maxUserLen":       {{ sakura.maxUsernameLength }},
                "minPwdEntropy":    {{ sakura.minPwdEntropy }},
                "checkLogin":       {% if session.checkLogin %}true{% else %}false{% endif %}

            };

            // Space for things that need to happen onload
            window.addEventListener("load", function() {

            {% if session.checkLogin %}
                // Convert href to object in logout link
                prepareAjaxLink('headerLogoutLink', 'submitPost', ', true, "Logging out..."');
            {% elseif not sakura.lockAuth and php.self != '/authenticate.php' %}
                // Make the header login form dynamic
                prepareAjaxForm('headerLoginForm', 'Logging in...');
            {% endif %}

            {% if session.checkLogin %}
                // Make notification requests (there's a seperate one to make it happen before the first 60 seconds)
                notifyRequest('{{ php.sessionid }}');

                // Create interval
                setInterval(function() {
                    notifyRequest('{{ php.sessionid }}');
                }, 60000);
            {% endif %}

            {% if php.self == '/profile.php' and session.checkLogin and user.data.user_id != profile.user.user_id %}
                // Make friend button dynamic
                prepareAjaxLink('profileFriendToggle', 'submitPost', ', true, "{% if profile.friend == 0 %}Adding{% else %}Removing{% endif %} friend..."');
            {% endif %}

            {% if php.self == '/viewtopic.php' and session.checkLogin %}
                var forumFriendToggles = document.querySelectorAll('.forum-friend-toggle');

                for(var i in forumFriendToggles) {
                    prepareAjaxLink(forumFriendToggles[i], 'submitPost', ', true, "Please wait..."');
                }
            {% endif %}

            {% if php.self == '/authenticate.php' and not sakura.lockAuth %}

                // AJAX Form Submission
                var forms = {
                    {% if not auth.changingPass %}
                        "loginForm": 'Logging in...',
                    {% if not sakura.disableRegistration %}
                        "registerForm": 'Processing registration...',
                    {% endif %}
                    {% if not sakura.requireActivation %}
                        "resendForm": 'Attempting to resend activation...',
                    {% endif %}
                        "passwordForm": 'Sending password recovery mail...'
                    {% else %}
                        "passwordForm": 'Changing password...'
                    {% endif %}
                };

                for(var i in forms) {
                    prepareAjaxForm(i, forms[i], (i == 'registerForm'));
                }

            {% endif %}

            {% if php.self == '/profile.php' ? (profile.data.user_data.profileBackground and not profile.data.user_data.userOptions.disableProfileParallax) : (user.checkPermission('SITE', 'CREATE_BACKGROUND') and user.data.user_data.userOptions.profileBackgroundSiteWide and user.data.user_data.profileBackground and not user.data.user_data.userOptions.disableProfileParallax) %}

                initialiseParallax('userBackground');

            {% endif %}

                if(!cookieData('get', sakuraVars.cookie.prefix +'accept_cookies')) {

                    notifyUI({
                        "title":    sakuraVars.siteName + " uses cookies!",
                        "text":     "Click this if you're OK with that and want to hide this message.",
                        "img":      "FONT:fa-asterisk",
                        "link":     "javascript:cookieData('set', '"+ sakuraVars.cookie.prefix +"accept_cookies', 'true; expires="+ (new Date(2147483647000)).toUTCString() +"');notifyClose(this.parentNode.id);"
                    });

                }

            });

            // Error reporter
            window.onerror = function(msg, url, line, col, error) {
                notifyUI({
                    "title":    "An error has occurred!",
                    "text":     "There was a problem while executing the JavaScript code for this page: " + msg + ", URL: " + url + ", Line: " + line + ", Column: " + col + ". Please report this to a developer.",
                    "img":      "FONT:fa-warning"
                });
            }

        </script>
{{ block('js') }}
    </head>
    <body>
        <div id="container">
            <span id="top"></span>
            <div class="header" id="header">
                <a class="logo" href="{{ urls.format('SITE_HOME') }}">{% if sakura.siteLogo %}<img src="{{ sakura.siteLogo }}" alt="{{ sakura.siteName }}" />{% else %}{{ sakura.siteName }}{% endif %}</a>
                <div class="menu fa">
                    <div class="menu-nav" id="navMenuSite">
                        <!-- Navigation menu, displayed on left side of the bar. -->
                        <a class="menu-item fa-home" href="{{ urls.format('SITE_HOME') }}" title="Home"></a>
                        <a class="menu-item fa-newspaper-o" href="{{ urls.format('SITE_NEWS') }}" title="News"></a>
                        <a class="menu-item fa-commenting" href="//chat.{{ sakura.urlMain }}/" title="Chat"></a>
                        <a class="menu-item fa-list" href="{{ urls.format('FORUM_INDEX') }}" title="Forums"></a>
                        <a class="menu-item fa-search" href="{{ urls.format('SITE_SEARCH') }}" title="Search"></a>
                        {% if session.checkLogin %}
                            <a class="menu-item fa-users" href="{{ urls.format('MEMBERLIST_INDEX') }}" title="Members"></a>
                            <a class="menu-item fa-heart" href="{{ urls.format('SITE_PREMIUM') }}" title="Support us"></a>
                        {% endif %}
                    </div>
                    <div class="menu-ucp" id="navMenuUser">
                        <!-- User menu, displayed on right side of the bar. -->
                        {% if session.checkLogin %}
                            <a class="menu-item avatar" href="{{ urls.format('USER_PROFILE', [user.data.user_id]) }}" title="Logged in as {{ user.data.username }}" style="background-image: url('{{ urls.format('IMAGE_AVATAR', [user.data.user_id]) }}'); width: auto; color: {{ user.colour }}; border-color: {{ user.colour }}; font-weight: 700;"></a>
                            <a class="menu-item fa-envelope" href="{{ urls.format('SETTING_CAT', ['messages']) }}" title="Messages"></a>
                            <a class="menu-item fa-gavel" href="{{ urls.format('MANAGE_INDEX') }}" title="Manage"></a>
                            <a class="menu-item fa-cogs" href="{{ urls.format('SETTINGS_INDEX') }}" title="Settings"></a>
                            <a class="menu-item fa-sign-out" href="{{ urls.format('USER_LOGOUT', [php.time, php.sessionid, sakura.currentPage]) }}" title="Logout" id="headerLogoutLink"></a>
                        {% else %}
                            {% if sakura.lockAuth %}
                                <div class="menu-item fa-lock" style="padding-left: 10px; padding-right: 10px;" title="Authentication is locked"></div>
                            {% else %}
                                <a class="menu-item fa-sign-in" href="{{ urls.format('SITE_LOGIN') }}" title="Login"></a>
                            {% endif %}
                        {% endif %}
                    </div>
                </div>
            </div>
            <div id="contentwrapper">
                <div id="notifications"></div>
                {% if php.self == '/profile.php' ? profile.data.user_data.profileBackground : (user.checkPermission('SITE', 'CREATE_BACKGROUND') and user.data.user_data.userOptions.profileBackgroundSiteWide and user.data.user_data.profileBackground) %}
                    <div id="userBackground" style="background-image: url('{{ urls.format('IMAGE_BACKGROUND', [(php.self == '/profile.php' ? profile : user).data.user_id]) }}');"></div>
                {% endif %}
                {% if not session.checkLogin and php.self != '/authenticate.php' %}
                    <form method="post" action="{{ urls.format('AUTH_ACTION') }}" id="headerLoginForm">
                        <input type="hidden" name="redirect" value="{{ sakura.currentPage }}" />
                        <input type="hidden" name="session" value="{{ php.sessionid }}" />
                        <input type="hidden" name="time" value="{{ php.time }}" />
                        <input type="hidden" name="mode" value="login" />
                        <div>
                            <label for="headerLoginUserName">Username:</label>
                            <input type="text" id="headerLoginUserName" name="username" class="inputStyling" placeholder="Username" />
                        </div>
                        <div>
                            <label for="headerLoginPassword">Password:</label>
                            <input type="password" id="headerLoginPassword" name="password" class="inputStyling" placeholder="Password" />
                        </div>
                        <div>
                            <input type="checkbox" name="remember" id="headerLoginRemember" />
                            <label for="headerLoginRemember">Remember me</label>
                        </div>
                        <div>
                            <input type="submit" id="headerLoginButton" name="submit" class="inputStyling small" value="Login" />
                        </div>
                    </form>
                {% endif %}
                {% if user.checkPermission('SITE', 'RESTRICTED') %}
                    <div class="headerNotify" style="background: repeating-linear-gradient(-45deg, #B33, #B33 10px, #B00 10px, #B00 20px); color: #FFF; border: 1px solid #C00; box-shadow: 0px 0px 3px #C00;">
                        <h1>Your account is current in <span style="font-width: 700 !important;">restricted mode</span>!</h1>
                        <div>A staff member has set your account to restricted mode most likely due to violation of the rules. While restricted you won't be able to use most public features of the site. If you think this is a mistake please <a href="{{ urls.format('INFO_PAGE', ['contact']) }}" style="color: inherit;">get in touch with one of our staff members</a>.</div>
                    </div>
                {% endif %}
                <noscript>
                    <div class="headerNotify">
                        <h1>You have JavaScript disabled!</h1>
                        <p style="padding: 0 10px;">A lot of things on this site require JavaScript to be enabled (e.g. the chat), we try to keep both sides happy but it is highly recommended that you enable it (you'll also have to deal with this message being here if you don't enable it).</p>
                    </div>
                </noscript>

                {% block content %}
                    <h1 class="stylised" style="text-align: center; margin: 2em auto;">{{ php.self }} is now printing!</h1>
                {% endblock %}

                {# include 'global/chat.tpl' #}
            </div>
            <div class="footer">
                <div class="ftsections">
                    <div class="copycentre">{% if not sakura.versionInfo.stable %}<a href="https://sakura.flash.moe/#r{{ sakura.versionInfo.version }}" target="_blank">Sakura Revision {{ sakura.versionInfo.version }} Development</a>{% endif %} &copy; 2013-2015 <a href="https://flash.moe/" target="_blank">Flashwave</a>, <a href="https://circlestorm.net/">et al</a>. </div>
                    <ul class="ftsection">
                        <li class="fthead">General</li>
                        <li><a href="{{ urls.format('SITE_HOME') }}" title="Flashii Frontpage">Home</a></li>
                        <li><a href="{{ urls.format('SITE_NEWS') }}" title="Flashii News &amp; Updates">News</a></li>
                        <li><a href="{{ urls.format('SITE_SEARCH') }}" title="Do full-site search requests">Search</a></li>
                        <li><a href="{{ urls.format('INFO_PAGE', ['contact']) }}" title="Contact our Staff">Contact</a></li>
                        <li><a href="https://sakura.flash.moe" target="_blank" title="All the changes made to Sakura are listed here">Changelog</a></li>
                        <li><a href="{{ urls.format('SITE_PREMIUM') }}" title="Get Tenshi and help us pay the bills">Support us</a></li>
                    </ul>
                    <ul class="ftsection">
                        <li class="fthead">Community</li>
                        <li><a href="{{ urls.format('FORUM_INDEX') }}" title="Read and post on our forums">Forums</a></li>
                        <li><a href="https://twitter.com/_flashii" target="_blank" title="Follow us on Twitter for news messages that are too short for the news page">Twitter</a></li>
                        <li><a href="https://youtube.com/user/flashiinet" target="_blank" title="Our YouTube page where stuff barely ever gets uploaded, mainly used to archive community creations">YouTube</a></li>
                        <li><a href="https://steamcommunity.com/groups/flashiinet" target="_blank" title="Our Steam group, play games with other members on the site">Steam</a></li>
                        <li><a href="https://bitbucket.org/circlestorm" target="_blank" title="Our BitBucket organisation">BitBucket</a></li>
                        <li><a href="https://github.com/circlestorm" target="_blank" title="Our GitHub organisation">GitHub</a></li>
                    </ul>
                    <ul class="ftsection">
                        <li class="fthead">Information</li>
                        <li><a href="{{ urls.format('SITE_FAQ') }}" title="Questions that get Asked Frequently but not actually">FAQ</a></li>
                        <li><a href="{{ urls.format('INFO_PAGE', ['rules']) }}" title="Some Rules and Information kind of summing up the ToS">Rules</a></li>
                        <li><a href="//fiistat.us" target="_blank" title="Check the status on our Servers and related services">Server Status</a></li>
                        <li><a href="{{ urls.format('INFO_PAGE', ['terms']) }}" title="Our Terms of Service">Terms of Service</a></li>
                    </ul>
                </div>
            </div>
        </div>
        {% if not sakura.versionInfo.stable and php.self == '/index.php' and not page.id %}
        <script type="text/javascript" src="https://sakura.flash.moe/?get={{ sakura.versionInfo.version|slice(0, 4) }}-{{ sakura.versionInfo.version|slice(4, 2) }}-{{ sakura.versionInfo.version|slice(6, 2) }}&amp;variable=true"></script>
        <script type="text/javascript">
            // Column colours for actions
            var changelogColours = [
                'inherit', // Unknown
                '#2A2', // Added
                '#2AA', // Updated
                '#2AA', // Fixed
                '#A22', // Removed
                '#62C', // Exported
            ];

            window.addEventListener("load", function() {
                // Check if the changelog variable is an object
                if(typeof changelog === 'object') {
                    // Grab the index panel
                    var indexPanel = document.getElementById('indexPanel');

                    // Create the head container
                    var changelogTitle = document.createElement('div');
                    changelogTitle.className = 'head';
                    changelogTitle.style.marginBottom = '1px';

                    // Create a link
                    var changelogLink = document.createElement('a');
                    changelogLink.className = 'underline';
                    changelogLink.target = '_blank';
                    changelogLink.href = 'https://sakura.flash.moe/#r{{ sakura.versionInfo.version }}';

                    // Create the text container
                    var changelogTitleText = document.createTextNode('Changelog');

                    // Append everything
                    changelogLink.appendChild(changelogTitleText);
                    changelogTitle.appendChild(changelogLink);
                    indexPanel.appendChild(changelogTitle);

                    // Create changelog table
                    var changelogTable = document.createElement('table');
                    changelogTable.className = 'panelTable';

                    // Create and append all changelog entries
                    for (var i in changelog) {
                        // Create elements
                        var changelogRow = document.createElement('tr');
                        var changelogColumnAction = document.createElement('td');
                        var changelogColumnMessage = document.createElement('td');

                        // Set data
                        changelogColumnAction.appendChild(document.createTextNode(changelog[i]['change_action']['action_name']));
                        changelogColumnAction.style.background = changelogColours[changelog[i]['change_action']['action_id']];
                        changelogColumnMessage.appendChild(document.createTextNode(changelog[i]['change_message']));

                        // Append
                        changelogRow.appendChild(changelogColumnAction);
                        changelogRow.appendChild(changelogColumnMessage);
                        changelogTable.appendChild(changelogRow);
                    }

                    // Append it to indexPanel
                    indexPanel.appendChild(changelogTable);
                }
            });
        </script>
        {% endif %}
    </body>
</html>
