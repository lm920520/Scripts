




<!DOCTYPE html>
<html class="   ">
  <head prefix="og: http://ogp.me/ns# fb: http://ogp.me/ns/fb# object: http://ogp.me/ns/object# article: http://ogp.me/ns/article# profile: http://ogp.me/ns/profile#">
    <meta charset='utf-8'>
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    
    
    <title>scripts/BcupTristana.lua at master · buttercuper/scripts</title>
    <link rel="search" type="application/opensearchdescription+xml" href="/opensearch.xml" title="GitHub" />
    <link rel="fluid-icon" href="https://github.com/fluidicon.png" title="GitHub" />
    <link rel="apple-touch-icon" sizes="57x57" href="/apple-touch-icon-114.png" />
    <link rel="apple-touch-icon" sizes="114x114" href="/apple-touch-icon-114.png" />
    <link rel="apple-touch-icon" sizes="72x72" href="/apple-touch-icon-144.png" />
    <link rel="apple-touch-icon" sizes="144x144" href="/apple-touch-icon-144.png" />
    <meta property="fb:app_id" content="1401488693436528"/>

      <meta content="@github" name="twitter:site" /><meta content="summary" name="twitter:card" /><meta content="buttercuper/scripts" name="twitter:title" /><meta content="Contribute to scripts development by creating an account on GitHub." name="twitter:description" /><meta content="https://avatars2.githubusercontent.com/u/7757237?s=400" name="twitter:image:src" />
<meta content="GitHub" property="og:site_name" /><meta content="object" property="og:type" /><meta content="https://avatars2.githubusercontent.com/u/7757237?s=400" property="og:image" /><meta content="buttercuper/scripts" property="og:title" /><meta content="https://github.com/buttercuper/scripts" property="og:url" /><meta content="Contribute to scripts development by creating an account on GitHub." property="og:description" />

    <link rel="assets" href="https://assets-cdn.github.com/">
    <link rel="conduit-xhr" href="https://ghconduit.com:25035">
    <link rel="xhr-socket" href="/_sockets" />

    <meta name="msapplication-TileImage" content="/windows-tile.png" />
    <meta name="msapplication-TileColor" content="#ffffff" />
    <meta name="selected-link" value="repo_source" data-pjax-transient />
      <meta name="google-analytics" content="UA-3769691-2">

    <meta content="collector.githubapp.com" name="octolytics-host" /><meta content="collector-cdn.github.com" name="octolytics-script-host" /><meta content="github" name="octolytics-app-id" /><meta content="B242F86F:446A:B052C2:53B5CFE9" name="octolytics-dimension-request_id" /><meta content="7712442" name="octolytics-actor-id" /><meta content="HFPDarkAlex" name="octolytics-actor-login" /><meta content="508bf95899bdb87f15ff4edc538f1c835a370b110e88f047da633d8194562a1c" name="octolytics-actor-hash" />
    

    
    
    <link rel="icon" type="image/x-icon" href="https://assets-cdn.github.com/favicon.ico" />


    <meta content="authenticity_token" name="csrf-param" />
<meta content="qFZVBz96pQSE311mFAKEO2HrO7m5moOyVZ87ApQSwZqEi2PRXaelAwclMoXBryihDxKBT1ItzTAf5xLEfwFyVQ==" name="csrf-token" />

    <link href="https://assets-cdn.github.com/assets/github-a3943029fb2330481c4a6367eccd68e84b5cb8d7.css" media="all" rel="stylesheet" type="text/css" />
    <link href="https://assets-cdn.github.com/assets/github2-341cafbd93d1df8a5d7e352ca90848007a622fb6.css" media="all" rel="stylesheet" type="text/css" />
    


    <meta http-equiv="x-pjax-version" content="87282c6a0913ea55f0df82b4d7953ff8">

      
  <meta name="description" content="Contribute to scripts development by creating an account on GitHub." />


  <meta content="7757237" name="octolytics-dimension-user_id" /><meta content="buttercuper" name="octolytics-dimension-user_login" /><meta content="21338896" name="octolytics-dimension-repository_id" /><meta content="buttercuper/scripts" name="octolytics-dimension-repository_nwo" /><meta content="true" name="octolytics-dimension-repository_public" /><meta content="false" name="octolytics-dimension-repository_is_fork" /><meta content="21338896" name="octolytics-dimension-repository_network_root_id" /><meta content="buttercuper/scripts" name="octolytics-dimension-repository_network_root_nwo" />

  <link href="https://github.com/buttercuper/scripts/commits/master.atom" rel="alternate" title="Recent Commits to scripts:master" type="application/atom+xml" />

  </head>


  <body class="logged_in  env-production windows vis-public page-blob">
    <a href="#start-of-content" tabindex="1" class="accessibility-aid js-skip-to-content">Skip to content</a>
    <div class="wrapper">
      
      
      
      


      <div class="header header-logged-in true">
  <div class="container clearfix">

    <a class="header-logo-invertocat" href="https://github.com/" aria-label="Homepage">
  <span class="mega-octicon octicon-mark-github"></span>
</a>


    
    <a href="/notifications" aria-label="You have no unread notifications" class="notification-indicator tooltipped tooltipped-s" data-hotkey="g n">
        <span class="mail-status all-read"></span>
</a>

      <div class="command-bar js-command-bar  in-repository">
          <form accept-charset="UTF-8" action="/search" class="command-bar-form" id="top_search_form" method="get">

<div class="commandbar">
  <span class="message"></span>
  <input type="text" data-hotkey="s" name="q" id="js-command-bar-field" placeholder="Search or type a command" tabindex="1" autocapitalize="off"
    
    data-username="HFPDarkAlex"
      data-repo="buttercuper/scripts"
      data-branch="master"
      data-sha="59b7a5fcb3a969739cc590962042d40e989211a5"
  >
  <div class="display hidden"></div>
</div>

    <input type="hidden" name="nwo" value="buttercuper/scripts" />

    <div class="select-menu js-menu-container js-select-menu search-context-select-menu">
      <span class="minibutton select-menu-button js-menu-target" role="button" aria-haspopup="true">
        <span class="js-select-button">This repository</span>
      </span>

      <div class="select-menu-modal-holder js-menu-content js-navigation-container" aria-hidden="true">
        <div class="select-menu-modal">

          <div class="select-menu-item js-navigation-item js-this-repository-navigation-item selected">
            <span class="select-menu-item-icon octicon octicon-check"></span>
            <input type="radio" class="js-search-this-repository" name="search_target" value="repository" checked="checked" />
            <div class="select-menu-item-text js-select-button-text">This repository</div>
          </div> <!-- /.select-menu-item -->

          <div class="select-menu-item js-navigation-item js-all-repositories-navigation-item">
            <span class="select-menu-item-icon octicon octicon-check"></span>
            <input type="radio" name="search_target" value="global" />
            <div class="select-menu-item-text js-select-button-text">All repositories</div>
          </div> <!-- /.select-menu-item -->

        </div>
      </div>
    </div>

  <span class="help tooltipped tooltipped-s" aria-label="Show command bar help">
    <span class="octicon octicon-question"></span>
  </span>


  <input type="hidden" name="ref" value="cmdform">

</form>
        <ul class="top-nav">
          <li class="explore"><a href="/explore">Explore</a></li>
            <li><a href="https://gist.github.com">Gist</a></li>
            <li><a href="/blog">Blog</a></li>
          <li><a href="https://help.github.com">Help</a></li>
        </ul>
      </div>

    


  <ul id="user-links">
    <li>
      <a href="/HFPDarkAlex" class="name">
        <img alt="HFPDarkAlex" class=" js-avatar" data-user="7712442" height="20" src="https://avatars3.githubusercontent.com/u/7712442?s=140" width="20" /> HFPDarkAlex
      </a>
    </li>

    <li class="new-menu dropdown-toggle js-menu-container">
      <a href="#" class="js-menu-target tooltipped tooltipped-s" aria-label="Create new...">
        <span class="octicon octicon-plus"></span>
        <span class="dropdown-arrow"></span>
      </a>

      <div class="new-menu-content js-menu-content">
      </div>
    </li>

    <li>
      <a href="/settings/profile" id="account_settings"
        class="tooltipped tooltipped-s"
        aria-label="Account settings ">
        <span class="octicon octicon-tools"></span>
      </a>
    </li>
    <li>
      <form class="logout-form" action="/logout" method="post">
        <button class="sign-out-button tooltipped tooltipped-s" aria-label="Sign out">
          <span class="octicon octicon-sign-out"></span>
        </button>
      </form>
    </li>

  </ul>

<div class="js-new-dropdown-contents hidden">
  

<ul class="dropdown-menu">
  <li>
    <a href="/new"><span class="octicon octicon-repo"></span> New repository</a>
  </li>
  <li>
    <a href="/organizations/new"><span class="octicon octicon-organization"></span> New organization</a>
  </li>


    <li class="section-title">
      <span title="buttercuper/scripts">This repository</span>
    </li>
      <li>
        <a href="/buttercuper/scripts/issues/new"><span class="octicon octicon-issue-opened"></span> New issue</a>
      </li>
</ul>

</div>


    
  </div>
</div>

      

        



      <div id="start-of-content" class="accessibility-aid"></div>
          <div class="site" itemscope itemtype="http://schema.org/WebPage">
    <div id="js-flash-container">
      
    </div>
    <div class="pagehead repohead instapaper_ignore readability-menu">
      <div class="container">
        
<ul class="pagehead-actions">

    <li class="subscription">
      <form accept-charset="UTF-8" action="/notifications/subscribe" class="js-social-container" data-autosubmit="true" data-remote="true" method="post"><div style="margin:0;padding:0;display:inline"><input name="authenticity_token" type="hidden" value="kv77ibbzWWbj2BCb7h9a5UIVKGzVjB2Obb2A271W/S6opRnff5OguOFHSdOL74PBF7ElrUTbOZma0f7DaU6TzQ==" /></div>  <input id="repository_id" name="repository_id" type="hidden" value="21338896" />

    <div class="select-menu js-menu-container js-select-menu">
      <a class="social-count js-social-count" href="/buttercuper/scripts/watchers">
        1
      </a>
      <span class="minibutton select-menu-button with-count js-menu-target" role="button" tabindex="0" aria-haspopup="true">
        <span class="js-select-button">
          <span class="octicon octicon-eye"></span>
          Watch
        </span>
      </span>

      <div class="select-menu-modal-holder">
        <div class="select-menu-modal subscription-menu-modal js-menu-content" aria-hidden="true">
          <div class="select-menu-header">
            <span class="select-menu-title">Notifications</span>
            <span class="octicon octicon-x js-menu-close"></span>
          </div> <!-- /.select-menu-header -->

          <div class="select-menu-list js-navigation-container" role="menu">

            <div class="select-menu-item js-navigation-item selected" role="menuitem" tabindex="0">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <div class="select-menu-item-text">
                <input checked="checked" id="do_included" name="do" type="radio" value="included" />
                <h4>Not watching</h4>
                <span class="description">Be notified when participating or @mentioned.</span>
                <span class="js-select-button-text hidden-select-button-text">
                  <span class="octicon octicon-eye"></span>
                  Watch
                </span>
              </div>
            </div> <!-- /.select-menu-item -->

            <div class="select-menu-item js-navigation-item " role="menuitem" tabindex="0">
              <span class="select-menu-item-icon octicon octicon octicon-check"></span>
              <div class="select-menu-item-text">
                <input id="do_subscribed" name="do" type="radio" value="subscribed" />
                <h4>Watching</h4>
                <span class="description">Be notified of all conversations.</span>
                <span class="js-select-button-text hidden-select-button-text">
                  <span class="octicon octicon-eye"></span>
                  Unwatch
                </span>
              </div>
            </div> <!-- /.select-menu-item -->

            <div class="select-menu-item js-navigation-item " role="menuitem" tabindex="0">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <div class="select-menu-item-text">
                <input id="do_ignore" name="do" type="radio" value="ignore" />
                <h4>Ignoring</h4>
                <span class="description">Never be notified.</span>
                <span class="js-select-button-text hidden-select-button-text">
                  <span class="octicon octicon-mute"></span>
                  Stop ignoring
                </span>
              </div>
            </div> <!-- /.select-menu-item -->

          </div> <!-- /.select-menu-list -->

        </div> <!-- /.select-menu-modal -->
      </div> <!-- /.select-menu-modal-holder -->
    </div> <!-- /.select-menu -->

</form>
    </li>

  <li>
    

  <div class="js-toggler-container js-social-container starring-container ">

    <form accept-charset="UTF-8" action="/buttercuper/scripts/unstar" class="js-toggler-form starred" data-remote="true" method="post"><div style="margin:0;padding:0;display:inline"><input name="authenticity_token" type="hidden" value="AxxBOJn81RTUAUS7prgYhU2fOl+tnB+fPHjUVW8qOXAbVY5xQ1j71bypkhplwkFCagNmeWspZIvTT9epkH2Nlw==" /></div>
      <button
        class="minibutton with-count js-toggler-target star-button"
        aria-label="Unstar this repository" title="Unstar buttercuper/scripts">
        <span class="octicon octicon-star"></span>
        Unstar
      </button>
        <a class="social-count js-social-count" href="/buttercuper/scripts/stargazers">
          0
        </a>
</form>
    <form accept-charset="UTF-8" action="/buttercuper/scripts/star" class="js-toggler-form unstarred" data-remote="true" method="post"><div style="margin:0;padding:0;display:inline"><input name="authenticity_token" type="hidden" value="ZwSZDiYuS8kYAPe98CsCmNi36wl9es6ZO6+VzCZD9L5Bsdb7urtH+KHbKr26EXY3mjdA9FdkkliEeeoqXA1CTw==" /></div>
      <button
        class="minibutton with-count js-toggler-target star-button"
        aria-label="Star this repository" title="Star buttercuper/scripts">
        <span class="octicon octicon-star"></span>
        Star
      </button>
        <a class="social-count js-social-count" href="/buttercuper/scripts/stargazers">
          0
        </a>
</form>  </div>

  </li>


        <li>
          <a href="/buttercuper/scripts/fork" class="minibutton with-count js-toggler-target fork-button lighter tooltipped-n" title="Fork your own copy of buttercuper/scripts to your account" aria-label="Fork your own copy of buttercuper/scripts to your account" rel="nofollow" data-method="post">
            <span class="octicon octicon-repo-forked"></span>
            Fork
          </a>
          <a href="/buttercuper/scripts/network" class="social-count">0</a>
        </li>

</ul>

        <h1 itemscope itemtype="http://data-vocabulary.org/Breadcrumb" class="entry-title public">
          <span class="repo-label"><span>public</span></span>
          <span class="mega-octicon octicon-repo"></span>
          <span class="author"><a href="/buttercuper" class="url fn" itemprop="url" rel="author"><span itemprop="title">buttercuper</span></a></span><!--
       --><span class="path-divider">/</span><!--
       --><strong><a href="/buttercuper/scripts" class="js-current-repository js-repo-home-link">scripts</a></strong>

          <span class="page-context-loader">
            <img alt="" height="16" src="https://assets-cdn.github.com/images/spinners/octocat-spinner-32.gif" width="16" />
          </span>

        </h1>
      </div><!-- /.container -->
    </div><!-- /.repohead -->

    <div class="container">
      <div class="repository-with-sidebar repo-container new-discussion-timeline js-new-discussion-timeline  ">
        <div class="repository-sidebar clearfix">
            

<div class="sunken-menu vertical-right repo-nav js-repo-nav js-repository-container-pjax js-octicon-loaders">
  <div class="sunken-menu-contents">
    <ul class="sunken-menu-group">
      <li class="tooltipped tooltipped-w" aria-label="Code">
        <a href="/buttercuper/scripts" aria-label="Code" class="selected js-selected-navigation-item sunken-menu-item" data-hotkey="g c" data-pjax="true" data-selected-links="repo_source repo_downloads repo_commits repo_releases repo_tags repo_branches /buttercuper/scripts">
          <span class="octicon octicon-code"></span> <span class="full-word">Code</span>
          <img alt="" class="mini-loader" height="16" src="https://assets-cdn.github.com/images/spinners/octocat-spinner-32.gif" width="16" />
</a>      </li>

        <li class="tooltipped tooltipped-w" aria-label="Issues">
          <a href="/buttercuper/scripts/issues" aria-label="Issues" class="js-selected-navigation-item sunken-menu-item js-disable-pjax" data-hotkey="g i" data-selected-links="repo_issues /buttercuper/scripts/issues">
            <span class="octicon octicon-issue-opened"></span> <span class="full-word">Issues</span>
            <span class='counter'>0</span>
            <img alt="" class="mini-loader" height="16" src="https://assets-cdn.github.com/images/spinners/octocat-spinner-32.gif" width="16" />
</a>        </li>

      <li class="tooltipped tooltipped-w" aria-label="Pull Requests">
        <a href="/buttercuper/scripts/pulls" aria-label="Pull Requests" class="js-selected-navigation-item sunken-menu-item js-disable-pjax" data-hotkey="g p" data-selected-links="repo_pulls /buttercuper/scripts/pulls">
            <span class="octicon octicon-git-pull-request"></span> <span class="full-word">Pull Requests</span>
            <span class='counter'>0</span>
            <img alt="" class="mini-loader" height="16" src="https://assets-cdn.github.com/images/spinners/octocat-spinner-32.gif" width="16" />
</a>      </li>


        <li class="tooltipped tooltipped-w" aria-label="Wiki">
          <a href="/buttercuper/scripts/wiki" aria-label="Wiki" class="js-selected-navigation-item sunken-menu-item js-disable-pjax" data-hotkey="g w" data-selected-links="repo_wiki /buttercuper/scripts/wiki">
            <span class="octicon octicon-book"></span> <span class="full-word">Wiki</span>
            <img alt="" class="mini-loader" height="16" src="https://assets-cdn.github.com/images/spinners/octocat-spinner-32.gif" width="16" />
</a>        </li>
    </ul>
    <div class="sunken-menu-separator"></div>
    <ul class="sunken-menu-group">

      <li class="tooltipped tooltipped-w" aria-label="Pulse">
        <a href="/buttercuper/scripts/pulse" aria-label="Pulse" class="js-selected-navigation-item sunken-menu-item" data-pjax="true" data-selected-links="pulse /buttercuper/scripts/pulse">
          <span class="octicon octicon-pulse"></span> <span class="full-word">Pulse</span>
          <img alt="" class="mini-loader" height="16" src="https://assets-cdn.github.com/images/spinners/octocat-spinner-32.gif" width="16" />
</a>      </li>

      <li class="tooltipped tooltipped-w" aria-label="Graphs">
        <a href="/buttercuper/scripts/graphs" aria-label="Graphs" class="js-selected-navigation-item sunken-menu-item" data-pjax="true" data-selected-links="repo_graphs repo_contributors /buttercuper/scripts/graphs">
          <span class="octicon octicon-graph"></span> <span class="full-word">Graphs</span>
          <img alt="" class="mini-loader" height="16" src="https://assets-cdn.github.com/images/spinners/octocat-spinner-32.gif" width="16" />
</a>      </li>

      <li class="tooltipped tooltipped-w" aria-label="Network">
        <a href="/buttercuper/scripts/network" aria-label="Network" class="js-selected-navigation-item sunken-menu-item js-disable-pjax" data-selected-links="repo_network /buttercuper/scripts/network">
          <span class="octicon octicon-repo-forked"></span> <span class="full-word">Network</span>
          <img alt="" class="mini-loader" height="16" src="https://assets-cdn.github.com/images/spinners/octocat-spinner-32.gif" width="16" />
</a>      </li>
    </ul>


  </div>
</div>

              <div class="only-with-full-nav">
                

  

<div class="clone-url open"
  data-protocol-type="http"
  data-url="/users/set_protocol?protocol_selector=http&amp;protocol_type=clone">
  <h3><strong>HTTPS</strong> clone URL</h3>
  <div class="clone-url-box">
    <input type="text" class="clone js-url-field"
           value="https://github.com/buttercuper/scripts.git" readonly="readonly">
    <span class="url-box-clippy">
    <button aria-label="Copy to clipboard" class="js-zeroclipboard minibutton zeroclipboard-button" data-clipboard-text="https://github.com/buttercuper/scripts.git" data-copied-hint="Copied!" type="button"><span class="octicon octicon-clippy"></span></button>
    </span>
  </div>
</div>

  

<div class="clone-url "
  data-protocol-type="ssh"
  data-url="/users/set_protocol?protocol_selector=ssh&amp;protocol_type=clone">
  <h3><strong>SSH</strong> clone URL</h3>
  <div class="clone-url-box">
    <input type="text" class="clone js-url-field"
           value="git@github.com:buttercuper/scripts.git" readonly="readonly">
    <span class="url-box-clippy">
    <button aria-label="Copy to clipboard" class="js-zeroclipboard minibutton zeroclipboard-button" data-clipboard-text="git@github.com:buttercuper/scripts.git" data-copied-hint="Copied!" type="button"><span class="octicon octicon-clippy"></span></button>
    </span>
  </div>
</div>

  

<div class="clone-url "
  data-protocol-type="subversion"
  data-url="/users/set_protocol?protocol_selector=subversion&amp;protocol_type=clone">
  <h3><strong>Subversion</strong> checkout URL</h3>
  <div class="clone-url-box">
    <input type="text" class="clone js-url-field"
           value="https://github.com/buttercuper/scripts" readonly="readonly">
    <span class="url-box-clippy">
    <button aria-label="Copy to clipboard" class="js-zeroclipboard minibutton zeroclipboard-button" data-clipboard-text="https://github.com/buttercuper/scripts" data-copied-hint="Copied!" type="button"><span class="octicon octicon-clippy"></span></button>
    </span>
  </div>
</div>


<p class="clone-options">You can clone with
      <a href="#" class="js-clone-selector" data-protocol="http">HTTPS</a>,
      <a href="#" class="js-clone-selector" data-protocol="ssh">SSH</a>,
      or <a href="#" class="js-clone-selector" data-protocol="subversion">Subversion</a>.
  <a href="https://help.github.com/articles/which-remote-url-should-i-use" class="help tooltipped tooltipped-n" aria-label="Get help on which URL is right for you.">
    <span class="octicon octicon-question"></span>
  </a>
</p>


  <a href="github-windows://openRepo/https://github.com/buttercuper/scripts" class="minibutton sidebar-button" title="Save buttercuper/scripts to your computer and use it in GitHub Desktop." aria-label="Save buttercuper/scripts to your computer and use it in GitHub Desktop.">
    <span class="octicon octicon-device-desktop"></span>
    Clone in Desktop
  </a>

                <a href="/buttercuper/scripts/archive/master.zip"
                   class="minibutton sidebar-button"
                   aria-label="Download buttercuper/scripts as a zip file"
                   title="Download buttercuper/scripts as a zip file"
                   rel="nofollow">
                  <span class="octicon octicon-cloud-download"></span>
                  Download ZIP
                </a>
              </div>
        </div><!-- /.repository-sidebar -->

        <div id="js-repo-pjax-container" class="repository-content context-loader-container" data-pjax-container>
          


<a href="/buttercuper/scripts/blob/b0220ffb5ef5ed463c412d814f27646e8dc76177/BcupTristana.lua" class="hidden js-permalink-shortcut" data-hotkey="y">Permalink</a>

<!-- blob contrib key: blob_contributors:v21:f4da594746ea06a6dc8f98919dddafca -->

<p title="This is a placeholder element" class="js-history-link-replace hidden"></p>

<div class="file-navigation">
  

<div class="select-menu js-menu-container js-select-menu" >
  <span class="minibutton select-menu-button js-menu-target css-truncate" data-hotkey="w"
    data-master-branch="master"
    data-ref="master"
    title="master"
    role="button" aria-label="Switch branches or tags" tabindex="0" aria-haspopup="true">
    <span class="octicon octicon-git-branch"></span>
    <i>branch:</i>
    <span class="js-select-button css-truncate-target">master</span>
  </span>

  <div class="select-menu-modal-holder js-menu-content js-navigation-container" data-pjax aria-hidden="true">

    <div class="select-menu-modal">
      <div class="select-menu-header">
        <span class="select-menu-title">Switch branches/tags</span>
        <span class="octicon octicon-x js-menu-close"></span>
      </div> <!-- /.select-menu-header -->

      <div class="select-menu-filters">
        <div class="select-menu-text-filter">
          <input type="text" aria-label="Filter branches/tags" id="context-commitish-filter-field" class="js-filterable-field js-navigation-enable" placeholder="Filter branches/tags">
        </div>
        <div class="select-menu-tabs">
          <ul>
            <li class="select-menu-tab">
              <a href="#" data-tab-filter="branches" class="js-select-menu-tab">Branches</a>
            </li>
            <li class="select-menu-tab">
              <a href="#" data-tab-filter="tags" class="js-select-menu-tab">Tags</a>
            </li>
          </ul>
        </div><!-- /.select-menu-tabs -->
      </div><!-- /.select-menu-filters -->

      <div class="select-menu-list select-menu-tab-bucket js-select-menu-tab-bucket" data-tab-filter="branches">

        <div data-filterable-for="context-commitish-filter-field" data-filterable-type="substring">


            <div class="select-menu-item js-navigation-item selected">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/buttercuper/scripts/blob/master/BcupTristana.lua"
                 data-name="master"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text css-truncate-target"
                 title="master">master</a>
            </div> <!-- /.select-menu-item -->
        </div>

          <div class="select-menu-no-results">Nothing to show</div>
      </div> <!-- /.select-menu-list -->

      <div class="select-menu-list select-menu-tab-bucket js-select-menu-tab-bucket" data-tab-filter="tags">
        <div data-filterable-for="context-commitish-filter-field" data-filterable-type="substring">


        </div>

        <div class="select-menu-no-results">Nothing to show</div>
      </div> <!-- /.select-menu-list -->

    </div> <!-- /.select-menu-modal -->
  </div> <!-- /.select-menu-modal-holder -->
</div> <!-- /.select-menu -->

  <div class="button-group right">
    <a href="/buttercuper/scripts/find/master"
          class="js-show-file-finder minibutton empty-icon tooltipped tooltipped-s"
          data-pjax
          data-hotkey="t"
          aria-label="Quickly jump between files">
      <span class="octicon octicon-list-unordered"></span>
    </a>
    <button class="js-zeroclipboard minibutton zeroclipboard-button"
          data-clipboard-text="BcupTristana.lua"
          aria-label="Copy to clipboard"
          data-copied-hint="Copied!">
      <span class="octicon octicon-clippy"></span>
    </button>
  </div>

  <div class="breadcrumb">
    <span class='repo-root js-repo-root'><span itemscope="" itemtype="http://data-vocabulary.org/Breadcrumb"><a href="/buttercuper/scripts" data-branch="master" data-direction="back" data-pjax="true" itemscope="url"><span itemprop="title">scripts</span></a></span></span><span class="separator"> / </span><strong class="final-path">BcupTristana.lua</strong>
  </div>
</div>


  <div class="commit file-history-tease">
      <img alt="buttercuper" class="main-avatar js-avatar" data-user="7757237" height="24" src="https://avatars1.githubusercontent.com/u/7757237?s=140" width="24" />
      <span class="author"><a href="/buttercuper" rel="author">buttercuper</a></span>
      <time datetime="2014-06-30T23:40:53-05:00" is="relative-time">June 30, 2014</time>
      <div class="commit-title">
          <a href="/buttercuper/scripts/commit/b0220ffb5ef5ed463c412d814f27646e8dc76177" class="message" data-pjax="true" title="Update BcupTristana.lua">Update BcupTristana.lua</a>
      </div>

    <div class="participation">
      <p class="quickstat"><a href="#blob_contributors_box" rel="facebox"><strong>1</strong>  contributor</a></p>
      
    </div>
    <div id="blob_contributors_box" style="display:none">
      <h2 class="facebox-header">Users who have contributed to this file</h2>
      <ul class="facebox-user-list">
          <li class="facebox-user-list-item">
            <img alt="buttercuper" class=" js-avatar" data-user="7757237" height="24" src="https://avatars1.githubusercontent.com/u/7757237?s=140" width="24" />
            <a href="/buttercuper">buttercuper</a>
          </li>
      </ul>
    </div>
  </div>

<div class="file-box">
  <div class="file">
    <div class="meta clearfix">
      <div class="info file-name">
        <span class="icon"><b class="octicon octicon-file-text"></b></span>
        <span class="mode" title="File Mode">file</span>
        <span class="meta-divider"></span>
          <span>178 lines (157 sloc)</span>
          <span class="meta-divider"></span>
        <span>6.66 kb</span>
      </div>
      <div class="actions">
        <div class="button-group">
            <a class="minibutton tooltipped tooltipped-w"
               href="github-windows://openRepo/https://github.com/buttercuper/scripts?branch=master&amp;filepath=BcupTristana.lua" aria-label="Open this file in GitHub for Windows">
                <span class="octicon octicon-device-desktop"></span> Open
            </a>
                <a class="minibutton tooltipped tooltipped-n js-update-url-with-hash"
                   aria-label="Clicking this button will automatically fork this project so you can edit the file"
                   href="/buttercuper/scripts/edit/master/BcupTristana.lua"
                   data-method="post" rel="nofollow">Edit</a>
          <a href="/buttercuper/scripts/raw/master/BcupTristana.lua" class="minibutton " id="raw-url">Raw</a>
            <a href="/buttercuper/scripts/blame/master/BcupTristana.lua" class="minibutton js-update-url-with-hash">Blame</a>
          <a href="/buttercuper/scripts/commits/master/BcupTristana.lua" class="minibutton " rel="nofollow">History</a>
        </div><!-- /.button-group -->

            <a class="minibutton danger empty-icon tooltipped tooltipped-s"
               href="/buttercuper/scripts/delete/master/BcupTristana.lua"
               aria-label="Fork this project and delete file"
               data-method="post" data-test-id="delete-blob-file" rel="nofollow">

          Delete
        </a>
      </div><!-- /.actions -->
    </div>
      
  <div class="blob-wrapper data type-lua js-blob-data">
       <table class="file-code file-diff tab-size-8">
         <tr class="file-code-line">
           <td class="blob-line-nums">
             <span id="L1" rel="#L1">1</span>
<span id="L2" rel="#L2">2</span>
<span id="L3" rel="#L3">3</span>
<span id="L4" rel="#L4">4</span>
<span id="L5" rel="#L5">5</span>
<span id="L6" rel="#L6">6</span>
<span id="L7" rel="#L7">7</span>
<span id="L8" rel="#L8">8</span>
<span id="L9" rel="#L9">9</span>
<span id="L10" rel="#L10">10</span>
<span id="L11" rel="#L11">11</span>
<span id="L12" rel="#L12">12</span>
<span id="L13" rel="#L13">13</span>
<span id="L14" rel="#L14">14</span>
<span id="L15" rel="#L15">15</span>
<span id="L16" rel="#L16">16</span>
<span id="L17" rel="#L17">17</span>
<span id="L18" rel="#L18">18</span>
<span id="L19" rel="#L19">19</span>
<span id="L20" rel="#L20">20</span>
<span id="L21" rel="#L21">21</span>
<span id="L22" rel="#L22">22</span>
<span id="L23" rel="#L23">23</span>
<span id="L24" rel="#L24">24</span>
<span id="L25" rel="#L25">25</span>
<span id="L26" rel="#L26">26</span>
<span id="L27" rel="#L27">27</span>
<span id="L28" rel="#L28">28</span>
<span id="L29" rel="#L29">29</span>
<span id="L30" rel="#L30">30</span>
<span id="L31" rel="#L31">31</span>
<span id="L32" rel="#L32">32</span>
<span id="L33" rel="#L33">33</span>
<span id="L34" rel="#L34">34</span>
<span id="L35" rel="#L35">35</span>
<span id="L36" rel="#L36">36</span>
<span id="L37" rel="#L37">37</span>
<span id="L38" rel="#L38">38</span>
<span id="L39" rel="#L39">39</span>
<span id="L40" rel="#L40">40</span>
<span id="L41" rel="#L41">41</span>
<span id="L42" rel="#L42">42</span>
<span id="L43" rel="#L43">43</span>
<span id="L44" rel="#L44">44</span>
<span id="L45" rel="#L45">45</span>
<span id="L46" rel="#L46">46</span>
<span id="L47" rel="#L47">47</span>
<span id="L48" rel="#L48">48</span>
<span id="L49" rel="#L49">49</span>
<span id="L50" rel="#L50">50</span>
<span id="L51" rel="#L51">51</span>
<span id="L52" rel="#L52">52</span>
<span id="L53" rel="#L53">53</span>
<span id="L54" rel="#L54">54</span>
<span id="L55" rel="#L55">55</span>
<span id="L56" rel="#L56">56</span>
<span id="L57" rel="#L57">57</span>
<span id="L58" rel="#L58">58</span>
<span id="L59" rel="#L59">59</span>
<span id="L60" rel="#L60">60</span>
<span id="L61" rel="#L61">61</span>
<span id="L62" rel="#L62">62</span>
<span id="L63" rel="#L63">63</span>
<span id="L64" rel="#L64">64</span>
<span id="L65" rel="#L65">65</span>
<span id="L66" rel="#L66">66</span>
<span id="L67" rel="#L67">67</span>
<span id="L68" rel="#L68">68</span>
<span id="L69" rel="#L69">69</span>
<span id="L70" rel="#L70">70</span>
<span id="L71" rel="#L71">71</span>
<span id="L72" rel="#L72">72</span>
<span id="L73" rel="#L73">73</span>
<span id="L74" rel="#L74">74</span>
<span id="L75" rel="#L75">75</span>
<span id="L76" rel="#L76">76</span>
<span id="L77" rel="#L77">77</span>
<span id="L78" rel="#L78">78</span>
<span id="L79" rel="#L79">79</span>
<span id="L80" rel="#L80">80</span>
<span id="L81" rel="#L81">81</span>
<span id="L82" rel="#L82">82</span>
<span id="L83" rel="#L83">83</span>
<span id="L84" rel="#L84">84</span>
<span id="L85" rel="#L85">85</span>
<span id="L86" rel="#L86">86</span>
<span id="L87" rel="#L87">87</span>
<span id="L88" rel="#L88">88</span>
<span id="L89" rel="#L89">89</span>
<span id="L90" rel="#L90">90</span>
<span id="L91" rel="#L91">91</span>
<span id="L92" rel="#L92">92</span>
<span id="L93" rel="#L93">93</span>
<span id="L94" rel="#L94">94</span>
<span id="L95" rel="#L95">95</span>
<span id="L96" rel="#L96">96</span>
<span id="L97" rel="#L97">97</span>
<span id="L98" rel="#L98">98</span>
<span id="L99" rel="#L99">99</span>
<span id="L100" rel="#L100">100</span>
<span id="L101" rel="#L101">101</span>
<span id="L102" rel="#L102">102</span>
<span id="L103" rel="#L103">103</span>
<span id="L104" rel="#L104">104</span>
<span id="L105" rel="#L105">105</span>
<span id="L106" rel="#L106">106</span>
<span id="L107" rel="#L107">107</span>
<span id="L108" rel="#L108">108</span>
<span id="L109" rel="#L109">109</span>
<span id="L110" rel="#L110">110</span>
<span id="L111" rel="#L111">111</span>
<span id="L112" rel="#L112">112</span>
<span id="L113" rel="#L113">113</span>
<span id="L114" rel="#L114">114</span>
<span id="L115" rel="#L115">115</span>
<span id="L116" rel="#L116">116</span>
<span id="L117" rel="#L117">117</span>
<span id="L118" rel="#L118">118</span>
<span id="L119" rel="#L119">119</span>
<span id="L120" rel="#L120">120</span>
<span id="L121" rel="#L121">121</span>
<span id="L122" rel="#L122">122</span>
<span id="L123" rel="#L123">123</span>
<span id="L124" rel="#L124">124</span>
<span id="L125" rel="#L125">125</span>
<span id="L126" rel="#L126">126</span>
<span id="L127" rel="#L127">127</span>
<span id="L128" rel="#L128">128</span>
<span id="L129" rel="#L129">129</span>
<span id="L130" rel="#L130">130</span>
<span id="L131" rel="#L131">131</span>
<span id="L132" rel="#L132">132</span>
<span id="L133" rel="#L133">133</span>
<span id="L134" rel="#L134">134</span>
<span id="L135" rel="#L135">135</span>
<span id="L136" rel="#L136">136</span>
<span id="L137" rel="#L137">137</span>
<span id="L138" rel="#L138">138</span>
<span id="L139" rel="#L139">139</span>
<span id="L140" rel="#L140">140</span>
<span id="L141" rel="#L141">141</span>
<span id="L142" rel="#L142">142</span>
<span id="L143" rel="#L143">143</span>
<span id="L144" rel="#L144">144</span>
<span id="L145" rel="#L145">145</span>
<span id="L146" rel="#L146">146</span>
<span id="L147" rel="#L147">147</span>
<span id="L148" rel="#L148">148</span>
<span id="L149" rel="#L149">149</span>
<span id="L150" rel="#L150">150</span>
<span id="L151" rel="#L151">151</span>
<span id="L152" rel="#L152">152</span>
<span id="L153" rel="#L153">153</span>
<span id="L154" rel="#L154">154</span>
<span id="L155" rel="#L155">155</span>
<span id="L156" rel="#L156">156</span>
<span id="L157" rel="#L157">157</span>
<span id="L158" rel="#L158">158</span>
<span id="L159" rel="#L159">159</span>
<span id="L160" rel="#L160">160</span>
<span id="L161" rel="#L161">161</span>
<span id="L162" rel="#L162">162</span>
<span id="L163" rel="#L163">163</span>
<span id="L164" rel="#L164">164</span>
<span id="L165" rel="#L165">165</span>
<span id="L166" rel="#L166">166</span>
<span id="L167" rel="#L167">167</span>
<span id="L168" rel="#L168">168</span>
<span id="L169" rel="#L169">169</span>
<span id="L170" rel="#L170">170</span>
<span id="L171" rel="#L171">171</span>
<span id="L172" rel="#L172">172</span>
<span id="L173" rel="#L173">173</span>
<span id="L174" rel="#L174">174</span>
<span id="L175" rel="#L175">175</span>
<span id="L176" rel="#L176">176</span>
<span id="L177" rel="#L177">177</span>
<span id="L178" rel="#L178">178</span>
<span id="L179" rel="#L179">179</span>
<span id="L180" rel="#L180">180</span>

           </td>
           <td class="blob-line-code"><div class="code-body highlight"><pre><div class='line' id='LC1'><span class="nb">require</span> <span class="s2">&quot;</span><span class="s">VPrediction&quot;</span></div><div class='line' id='LC2'><span class="nb">require</span> <span class="s2">&quot;</span><span class="s">SourceLib&quot;</span></div><div class='line' id='LC3'><span class="nb">require</span> <span class="s2">&quot;</span><span class="s">SOW&quot;</span></div><div class='line' id='LC4'><br/></div><div class='line' id='LC5'><span class="k">if</span> <span class="n">myHero</span><span class="p">.</span><span class="n">charName</span> <span class="o">~=</span> <span class="s2">&quot;</span><span class="s">Tristana&quot;</span> <span class="k">then</span> <span class="k">return</span> <span class="k">end</span></div><div class='line' id='LC6'><br/></div><div class='line' id='LC7'><br/></div><div class='line' id='LC8'><span class="n">champsToStun</span> <span class="o">=</span> <span class="p">{</span></div><div class='line' id='LC9'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="p">{</span> <span class="n">charName</span> <span class="o">=</span> <span class="s2">&quot;</span><span class="s">Katarina&quot;</span><span class="p">,</span>        <span class="n">spellName</span> <span class="o">=</span> <span class="s2">&quot;</span><span class="s">KatarinaR&quot;</span> <span class="p">,</span>                  <span class="n">important</span> <span class="o">=</span> <span class="mi">0</span><span class="p">},</span></div><div class='line' id='LC10'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="p">{</span> <span class="n">charName</span> <span class="o">=</span> <span class="s2">&quot;</span><span class="s">Galio&quot;</span><span class="p">,</span>           <span class="n">spellName</span> <span class="o">=</span> <span class="s2">&quot;</span><span class="s">GalioIdolOfDurand&quot;</span> <span class="p">,</span>          <span class="n">important</span> <span class="o">=</span> <span class="mi">0</span><span class="p">},</span></div><div class='line' id='LC11'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="p">{</span> <span class="n">charName</span> <span class="o">=</span> <span class="s2">&quot;</span><span class="s">FiddleSticks&quot;</span><span class="p">,</span>    <span class="n">spellName</span> <span class="o">=</span> <span class="s2">&quot;</span><span class="s">Crowstorm&quot;</span> <span class="p">,</span>                  <span class="n">important</span> <span class="o">=</span> <span class="mi">1</span><span class="p">},</span></div><div class='line' id='LC12'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="p">{</span> <span class="n">charName</span> <span class="o">=</span> <span class="s2">&quot;</span><span class="s">FiddleSticks&quot;</span><span class="p">,</span>    <span class="n">spellName</span> <span class="o">=</span> <span class="s2">&quot;</span><span class="s">DrainChannel&quot;</span> <span class="p">,</span>               <span class="n">important</span> <span class="o">=</span> <span class="mi">1</span><span class="p">},</span></div><div class='line' id='LC13'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="p">{</span> <span class="n">charName</span> <span class="o">=</span> <span class="s2">&quot;</span><span class="s">Nunu&quot;</span><span class="p">,</span>            <span class="n">spellName</span> <span class="o">=</span> <span class="s2">&quot;</span><span class="s">AbsoluteZero&quot;</span> <span class="p">,</span>               <span class="n">important</span> <span class="o">=</span> <span class="mi">0</span><span class="p">},</span></div><div class='line' id='LC14'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="p">{</span> <span class="n">charName</span> <span class="o">=</span> <span class="s2">&quot;</span><span class="s">Shen&quot;</span><span class="p">,</span>            <span class="n">spellName</span> <span class="o">=</span> <span class="s2">&quot;</span><span class="s">ShenStandUnited&quot;</span> <span class="p">,</span>            <span class="n">important</span> <span class="o">=</span> <span class="mi">0</span><span class="p">},</span></div><div class='line' id='LC15'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="p">{</span> <span class="n">charName</span> <span class="o">=</span> <span class="s2">&quot;</span><span class="s">Urgot&quot;</span><span class="p">,</span>           <span class="n">spellName</span> <span class="o">=</span> <span class="s2">&quot;</span><span class="s">UrgotSwap2&quot;</span> <span class="p">,</span>                 <span class="n">important</span> <span class="o">=</span> <span class="mi">0</span><span class="p">},</span></div><div class='line' id='LC16'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="p">{</span> <span class="n">charName</span> <span class="o">=</span> <span class="s2">&quot;</span><span class="s">Malzahar&quot;</span><span class="p">,</span>        <span class="n">spellName</span> <span class="o">=</span> <span class="s2">&quot;</span><span class="s">AlZaharNetherGrasp&quot;</span> <span class="p">,</span>         <span class="n">important</span> <span class="o">=</span> <span class="mi">0</span><span class="p">},</span></div><div class='line' id='LC17'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="p">{</span> <span class="n">charName</span> <span class="o">=</span> <span class="s2">&quot;</span><span class="s">Karthus&quot;</span><span class="p">,</span>         <span class="n">spellName</span> <span class="o">=</span> <span class="s2">&quot;</span><span class="s">FallenOne&quot;</span> <span class="p">,</span>                  <span class="n">important</span> <span class="o">=</span> <span class="mi">0</span><span class="p">},</span></div><div class='line' id='LC18'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="p">{</span> <span class="n">charName</span> <span class="o">=</span> <span class="s2">&quot;</span><span class="s">Pantheon&quot;</span><span class="p">,</span>        <span class="n">spellName</span> <span class="o">=</span> <span class="s2">&quot;</span><span class="s">PantheonRJump&quot;</span> <span class="p">,</span>              <span class="n">important</span> <span class="o">=</span> <span class="mi">0</span><span class="p">},</span></div><div class='line' id='LC19'>				<span class="p">{</span>  <span class="n">charName</span> <span class="o">=</span> <span class="s2">&quot;</span><span class="s">Pantheon&quot;</span><span class="p">,</span>        <span class="n">spellName</span> <span class="o">=</span> <span class="s2">&quot;</span><span class="s">PantheonRFall&quot;</span><span class="p">,</span>               <span class="n">important</span> <span class="o">=</span> <span class="mi">0</span><span class="p">},</span></div><div class='line' id='LC20'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="p">{</span> <span class="n">charName</span> <span class="o">=</span> <span class="s2">&quot;</span><span class="s">Varus&quot;</span><span class="p">,</span>           <span class="n">spellName</span> <span class="o">=</span> <span class="s2">&quot;</span><span class="s">VarusQ&quot;</span> <span class="p">,</span>                     <span class="n">important</span> <span class="o">=</span> <span class="mi">1</span><span class="p">},</span></div><div class='line' id='LC21'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="p">{</span> <span class="n">charName</span> <span class="o">=</span> <span class="s2">&quot;</span><span class="s">Caitlyn&quot;</span><span class="p">,</span>         <span class="n">spellName</span> <span class="o">=</span> <span class="s2">&quot;</span><span class="s">CaitlynAceintheHole&quot;</span> <span class="p">,</span>        <span class="n">important</span> <span class="o">=</span> <span class="mi">1</span><span class="p">},</span></div><div class='line' id='LC22'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="p">{</span> <span class="n">charName</span> <span class="o">=</span> <span class="s2">&quot;</span><span class="s">MissFortune&quot;</span><span class="p">,</span>     <span class="n">spellName</span> <span class="o">=</span> <span class="s2">&quot;</span><span class="s">MissFortuneBulletTime&quot;</span> <span class="p">,</span>      <span class="n">important</span> <span class="o">=</span> <span class="mi">1</span><span class="p">},</span></div><div class='line' id='LC23'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="p">{</span> <span class="n">charName</span> <span class="o">=</span> <span class="s2">&quot;</span><span class="s">Warwick&quot;</span><span class="p">,</span>         <span class="n">spellName</span> <span class="o">=</span> <span class="s2">&quot;</span><span class="s">InfiniteDuress&quot;</span> <span class="p">,</span>             <span class="n">important</span> <span class="o">=</span> <span class="mi">0</span><span class="p">}</span></div><div class='line' id='LC24'><span class="p">}</span></div><div class='line' id='LC25'><br/></div><div class='line' id='LC26'><br/></div><div class='line' id='LC27'><span class="k">function</span> <span class="nf">OnLoad</span><span class="p">()</span></div><div class='line' id='LC28'><span class="cm">--[[</span></div><div class='line' id='LC29'><span class="cm">	RapidFire = {charName = &quot;Tristana&quot;, spellSlot = &quot;Q&quot;, range = 0, width = 0, speed = math.huge, delay = .5, spellType = &quot;selfCast&quot;, riskLevel = &quot;noDmg&quot;, cc = false, hitLineCheck = false},</span></div><div class='line' id='LC30'><span class="cm">    RocketJump = {charName = &quot;Tristana&quot;, spellSlot = &quot;W&quot;, range = 900, width = 270, speed = 1150, delay = .5, spellType = &quot;skillShot&quot;, riskLevel = &quot;kill&quot;, cc = false, hitLineCheck = false},</span></div><div class='line' id='LC31'><span class="cm">    DetonatingShot = {charName = &quot;Tristana&quot;, spellSlot = &quot;E&quot;, range = 625, width = 0, speed = 1400, delay = .5, spellType = &quot;enemyCast&quot;, riskLevel = &quot;kill&quot;, cc = false, hitLineCheck = false},</span></div><div class='line' id='LC32'><span class="cm">    BusterShot = {charName = &quot;Tristana&quot;, spellSlot = &quot;R&quot;, range = 700, width = 0, speed = 1600, delay = .5, spellType = &quot;enemyCast&quot;, riskLevel = &quot;extreme&quot;, cc = true, hitLineCheck = false},</span></div><div class='line' id='LC33'><span class="cm">		]]</span></div><div class='line' id='LC34'>	<span class="n">VP</span> <span class="o">=</span> <span class="n">VPrediction</span><span class="p">()</span></div><div class='line' id='LC35'>	<span class="n">qRng</span><span class="p">,</span> <span class="n">wRng</span><span class="p">,</span> <span class="n">eRng</span><span class="p">,</span> <span class="n">rRng</span> <span class="o">=</span> <span class="p">(</span><span class="mi">550</span> <span class="o">+</span> <span class="mi">9</span> <span class="o">*</span><span class="p">(</span><span class="n">myHero</span><span class="p">.</span><span class="n">level</span> <span class="o">-</span> <span class="mi">1</span><span class="p">)),</span> <span class="mi">900</span><span class="p">,</span> <span class="p">(</span><span class="mi">550</span> <span class="o">+</span> <span class="mi">9</span> <span class="o">*</span><span class="p">(</span><span class="n">myHero</span><span class="p">.</span><span class="n">level</span> <span class="o">-</span> <span class="mi">1</span><span class="p">)),</span> <span class="p">(</span><span class="mi">550</span> <span class="o">+</span> <span class="mi">9</span> <span class="o">*</span> <span class="p">(</span><span class="n">myHero</span><span class="p">.</span><span class="n">level</span> <span class="o">-</span> <span class="mi">1</span><span class="p">))</span></div><div class='line' id='LC36'>	<span class="n">Q</span> <span class="o">=</span> <span class="n">Spell</span><span class="p">(</span><span class="n">_Q</span><span class="p">,</span> <span class="n">qRng</span><span class="p">)</span></div><div class='line' id='LC37'>	<span class="n">W</span> <span class="o">=</span> <span class="n">Spell</span><span class="p">(</span><span class="n">_W</span><span class="p">,</span> <span class="n">wRng</span><span class="p">):</span><span class="n">SetSkillshot</span><span class="p">(</span><span class="n">VP</span><span class="p">,</span> <span class="n">SKILLSHOT_CIRCULAR</span><span class="p">,</span> <span class="mi">270</span><span class="p">,</span> <span class="mf">0.5</span><span class="p">,</span> <span class="mi">1150</span><span class="p">,</span> <span class="kc">false</span><span class="p">)</span></div><div class='line' id='LC38'>	<span class="n">E</span> <span class="o">=</span> <span class="n">Spell</span><span class="p">(</span><span class="n">_E</span><span class="p">,</span> <span class="n">eRng</span><span class="p">)</span></div><div class='line' id='LC39'>	<span class="n">R</span> <span class="o">=</span> <span class="n">Spell</span><span class="p">(</span><span class="n">_R</span><span class="p">,</span> <span class="n">rRng</span><span class="p">)</span></div><div class='line' id='LC40'>	<span class="n">DLib</span> <span class="o">=</span> <span class="n">DamageLib</span><span class="p">()</span></div><div class='line' id='LC41'>	<span class="c1">--DamageLib:RegisterDamageSource(spellId, damagetype, basedamage, perlevel, scalingtype, scalingstat, percentscaling, condition, extra)</span></div><div class='line' id='LC42'>	<span class="n">DLib</span><span class="p">:</span><span class="n">RegisterDamageSource</span><span class="p">(</span><span class="n">_W</span><span class="p">,</span> <span class="n">_MAGIC</span><span class="p">,</span> <span class="mi">70</span><span class="p">,</span> <span class="mi">45</span><span class="p">,</span> <span class="n">_MAGIC</span><span class="p">,</span> <span class="n">_AP</span><span class="p">,</span> <span class="mf">0.80</span><span class="p">,</span> <span class="k">function</span><span class="p">()</span> <span class="k">return</span> <span class="p">(</span><span class="n">player</span><span class="p">:</span><span class="n">CanUseSpell</span><span class="p">(</span><span class="n">_W</span><span class="p">)</span> <span class="o">==</span> <span class="n">READY</span><span class="p">)</span><span class="k">end</span><span class="p">)</span></div><div class='line' id='LC43'>	<span class="n">DLib</span><span class="p">:</span><span class="n">RegisterDamageSource</span><span class="p">(</span><span class="n">_E</span><span class="p">,</span> <span class="n">_MAGIC</span><span class="p">,</span> <span class="mi">110</span><span class="p">,</span> <span class="mi">40</span><span class="p">,</span> <span class="n">_MAGIC</span><span class="p">,</span> <span class="n">_AP</span><span class="p">,</span> <span class="mi">1</span><span class="p">,</span> <span class="k">function</span><span class="p">()</span> <span class="k">return</span> <span class="p">(</span><span class="n">player</span><span class="p">:</span><span class="n">CanUseSpell</span><span class="p">(</span><span class="n">_E</span><span class="p">)</span> <span class="o">==</span> <span class="n">READY</span><span class="p">)</span><span class="k">end</span><span class="p">)</span></div><div class='line' id='LC44'>	<span class="n">DLib</span><span class="p">:</span><span class="n">RegisterDamageSource</span><span class="p">(</span><span class="n">_R</span><span class="p">,</span> <span class="n">_MAGIC</span><span class="p">,</span> <span class="mi">300</span><span class="p">,</span> <span class="mi">100</span><span class="p">,</span> <span class="n">_MAGIC</span><span class="p">,</span> <span class="n">_AP</span><span class="p">,</span> <span class="mf">1.5</span><span class="p">,</span> <span class="k">function</span><span class="p">()</span> <span class="k">return</span> <span class="p">(</span><span class="n">player</span><span class="p">:</span><span class="n">CanUseSpell</span><span class="p">(</span><span class="n">_R</span><span class="p">)</span> <span class="o">==</span> <span class="n">READY</span><span class="p">)</span><span class="k">end</span><span class="p">)</span></div><div class='line' id='LC45'>	<span class="n">DFG</span> <span class="o">=</span> <span class="n">Item</span><span class="p">(</span><span class="mi">3128</span><span class="p">,</span><span class="mi">750</span><span class="p">)</span></div><div class='line' id='LC46'><br/></div><div class='line' id='LC47'>	<span class="n">Config</span> <span class="o">=</span> <span class="n">scriptConfig</span><span class="p">(</span><span class="s2">&quot;</span><span class="s">Tristana&quot;</span><span class="p">,</span><span class="s2">&quot;</span><span class="s">Tristana&quot;</span><span class="p">)</span></div><div class='line' id='LC48'>	<span class="c1">-- Key Binds</span></div><div class='line' id='LC49'>	<span class="n">Config</span><span class="p">:</span><span class="n">addSubMenu</span><span class="p">(</span><span class="s2">&quot;</span><span class="s">Key Bindings&quot;</span><span class="p">,</span><span class="s2">&quot;</span><span class="s">bind&quot;</span><span class="p">)</span></div><div class='line' id='LC50'>	<span class="n">Config</span><span class="p">.</span><span class="n">bind</span><span class="p">:</span><span class="n">addParam</span><span class="p">(</span><span class="s2">&quot;</span><span class="s">active&quot;</span><span class="p">,</span> <span class="s2">&quot;</span><span class="s">Combo&quot;</span><span class="p">,</span> <span class="n">SCRIPT_PARAM_ONKEYDOWN</span><span class="p">,</span> <span class="kc">false</span><span class="p">,</span> <span class="mi">32</span><span class="p">)</span></div><div class='line' id='LC51'>	<span class="n">Config</span><span class="p">.</span><span class="n">bind</span><span class="p">:</span><span class="n">addParam</span><span class="p">(</span><span class="s2">&quot;</span><span class="s">harass&quot;</span><span class="p">,</span> <span class="s2">&quot;</span><span class="s">Harass&quot;</span><span class="p">,</span> <span class="n">SCRIPT_PARAM_ONKEYDOWN</span><span class="p">,</span> <span class="kc">false</span><span class="p">,</span> <span class="nb">string.byte</span><span class="p">(</span><span class="s2">&quot;</span><span class="s">C&quot;</span><span class="p">))</span></div><div class='line' id='LC52'>	<span class="n">Config</span><span class="p">.</span><span class="n">bind</span><span class="p">:</span><span class="n">addParam</span><span class="p">(</span><span class="s2">&quot;</span><span class="s">useW&quot;</span><span class="p">,</span> <span class="s2">&quot;</span><span class="s">Use W&quot;</span><span class="p">,</span> <span class="n">SCRIPT_PARAM_ONKEYTOGGLE</span><span class="p">,</span> <span class="kc">true</span><span class="p">,</span> <span class="nb">string.byte</span><span class="p">(</span><span class="s2">&quot;</span><span class="s">L&quot;</span><span class="p">))</span></div><div class='line' id='LC53'>	<span class="n">Config</span><span class="p">.</span><span class="n">bind</span><span class="p">:</span><span class="n">addParam</span><span class="p">(</span><span class="s2">&quot;</span><span class="s">auto&quot;</span><span class="p">,</span> <span class="s2">&quot;</span><span class="s">Auto Spell&quot;</span><span class="p">,</span> <span class="n">SCRIPT_PARAM_ONKEYTOGGLE</span><span class="p">,</span> <span class="kc">true</span><span class="p">,</span> <span class="nb">string.byte</span><span class="p">(</span><span class="s2">&quot;</span><span class="s">N&quot;</span><span class="p">))</span></div><div class='line' id='LC54'>	<span class="n">Config</span><span class="p">.</span><span class="n">bind</span><span class="p">:</span><span class="n">addParam</span><span class="p">(</span><span class="s2">&quot;</span><span class="s">interrupt&quot;</span><span class="p">,</span> <span class="s2">&quot;</span><span class="s">Interrupt With R&quot;</span><span class="p">,</span> <span class="n">SCRIPT_PARAM_ONKEYTOGGLE</span><span class="p">,</span> <span class="kc">true</span><span class="p">,</span><span class="nb">string.byte</span><span class="p">(</span><span class="s2">&quot;</span><span class="s">L&quot;</span><span class="p">))</span></div><div class='line' id='LC55'>	<span class="n">Config</span><span class="p">:</span><span class="n">addSubMenu</span><span class="p">(</span><span class="s2">&quot;</span><span class="s">Draw&quot;</span><span class="p">,</span><span class="s2">&quot;</span><span class="s">Draw&quot;</span><span class="p">)</span></div><div class='line' id='LC56'>	<span class="n">Config</span><span class="p">.</span><span class="n">Draw</span><span class="p">:</span><span class="n">addParam</span><span class="p">(</span><span class="s2">&quot;</span><span class="s">drawq&quot;</span><span class="p">,</span> <span class="s2">&quot;</span><span class="s">Draw Q&quot;</span><span class="p">,</span> <span class="n">SCRIPT_PARAM_ONOFF</span><span class="p">,</span> <span class="kc">true</span><span class="p">)</span></div><div class='line' id='LC57'>	<span class="n">Config</span><span class="p">.</span><span class="n">Draw</span><span class="p">:</span><span class="n">addParam</span><span class="p">(</span><span class="s2">&quot;</span><span class="s">draww&quot;</span><span class="p">,</span> <span class="s2">&quot;</span><span class="s">Draw W&quot;</span><span class="p">,</span> <span class="n">SCRIPT_PARAM_ONOFF</span><span class="p">,</span> <span class="kc">true</span><span class="p">)</span></div><div class='line' id='LC58'>	<span class="n">Config</span><span class="p">.</span><span class="n">Draw</span><span class="p">:</span><span class="n">addParam</span><span class="p">(</span><span class="s2">&quot;</span><span class="s">drawe&quot;</span><span class="p">,</span> <span class="s2">&quot;</span><span class="s">Draw E&quot;</span><span class="p">,</span> <span class="n">SCRIPT_PARAM_ONOFF</span><span class="p">,</span> <span class="kc">true</span><span class="p">)</span></div><div class='line' id='LC59'>	<span class="n">Config</span><span class="p">.</span><span class="n">Draw</span><span class="p">:</span><span class="n">addParam</span><span class="p">(</span><span class="s2">&quot;</span><span class="s">drawr&quot;</span><span class="p">,</span> <span class="s2">&quot;</span><span class="s">Draw R&quot;</span><span class="p">,</span> <span class="n">SCRIPT_PARAM_ONOFF</span><span class="p">,</span> <span class="kc">true</span><span class="p">)</span></div><div class='line' id='LC60'><br/></div><div class='line' id='LC61'>	<span class="n">Orbwalker</span> <span class="o">=</span> <span class="n">SOW</span><span class="p">(</span><span class="n">VP</span><span class="p">)</span></div><div class='line' id='LC62'>	<span class="n">Config</span><span class="p">:</span><span class="n">addSubMenu</span><span class="p">(</span><span class="s2">&quot;</span><span class="s">Orbwalker&quot;</span><span class="p">,</span> <span class="s2">&quot;</span><span class="s">SOWorb&quot;</span><span class="p">)</span></div><div class='line' id='LC63'>	<span class="n">Orbwalker</span><span class="p">:</span><span class="n">LoadToMenu</span><span class="p">(</span><span class="n">Config</span><span class="p">.</span><span class="n">SOWorb</span><span class="p">)</span></div><div class='line' id='LC64'><br/></div><div class='line' id='LC65'>	<span class="n">STS</span> <span class="o">=</span> <span class="n">SimpleTS</span><span class="p">(</span><span class="n">STS_PRIORITY_LESS_CAST_MAGIC</span><span class="p">)</span></div><div class='line' id='LC66'>	<span class="n">Config</span><span class="p">:</span><span class="n">addSubMenu</span><span class="p">(</span><span class="s2">&quot;</span><span class="s">Set Target Selector Priority&quot;</span><span class="p">,</span> <span class="s2">&quot;</span><span class="s">STS&quot;</span><span class="p">)</span></div><div class='line' id='LC67'>	<span class="n">STS</span><span class="p">:</span><span class="n">AddToMenu</span><span class="p">(</span><span class="n">Config</span><span class="p">.</span><span class="n">STS</span><span class="p">)</span></div><div class='line' id='LC68'>	<span class="n">Combo</span> <span class="o">=</span> <span class="p">{</span><span class="n">_W</span><span class="p">,</span> <span class="n">_E</span><span class="p">,</span> <span class="n">_R</span><span class="p">,</span><span class="n">_ITEMS</span><span class="p">}</span></div><div class='line' id='LC69'>	<span class="n">DLib</span><span class="p">:</span><span class="n">AddToMenu</span><span class="p">(</span><span class="n">Config</span><span class="p">.</span><span class="n">Draw</span><span class="p">,</span><span class="n">Combo</span><span class="p">)</span></div><div class='line' id='LC70'><br/></div><div class='line' id='LC71'>	<span class="n">PrintChat</span><span class="p">(</span><span class="s2">&quot;</span><span class="s">&lt;font color=&#39;#E97FA5&#39;&gt; &gt;&gt; BcupTristana Loaded!&lt;/font&gt;&quot;</span><span class="p">)</span></div><div class='line' id='LC72'><span class="k">end</span></div><div class='line' id='LC73'><br/></div><div class='line' id='LC74'><span class="k">function</span> <span class="nf">OnTick</span><span class="p">()</span></div><div class='line' id='LC75'>	<span class="n">target</span> <span class="o">=</span> <span class="n">STS</span><span class="p">:</span><span class="n">GetTarget</span><span class="p">(</span><span class="n">wRng</span><span class="p">)</span></div><div class='line' id='LC76'>	<span class="k">if</span> <span class="n">Config</span><span class="p">.</span><span class="n">bind</span><span class="p">.</span><span class="n">active</span> <span class="k">then</span></div><div class='line' id='LC77'>		<span class="n">active</span><span class="p">(</span><span class="n">target</span><span class="p">)</span></div><div class='line' id='LC78'>	<span class="k">end</span></div><div class='line' id='LC79'>	<span class="k">if</span> <span class="n">Config</span><span class="p">.</span><span class="n">bind</span><span class="p">.</span><span class="n">harass</span> <span class="k">then</span></div><div class='line' id='LC80'>		<span class="n">harass</span><span class="p">(</span><span class="n">target</span><span class="p">)</span></div><div class='line' id='LC81'>	<span class="k">end</span></div><div class='line' id='LC82'>	<span class="k">if</span> <span class="n">Config</span><span class="p">.</span><span class="n">bind</span><span class="p">.</span><span class="n">auto</span> <span class="k">then</span></div><div class='line' id='LC83'>		<span class="n">auto</span><span class="p">(</span><span class="n">target</span><span class="p">)</span></div><div class='line' id='LC84'>	<span class="k">end</span></div><div class='line' id='LC85'><span class="k">end</span></div><div class='line' id='LC86'><br/></div><div class='line' id='LC87'><span class="k">function</span> <span class="nf">OnDraw</span><span class="p">()</span></div><div class='line' id='LC88'>	<span class="k">if</span> <span class="n">Config</span><span class="p">.</span><span class="n">Draw</span><span class="p">.</span><span class="n">drawq</span> <span class="k">then</span></div><div class='line' id='LC89'>		<span class="n">DrawCircle</span><span class="p">(</span><span class="n">myHero</span><span class="p">.</span><span class="n">x</span><span class="p">,</span><span class="n">myHero</span><span class="p">.</span><span class="n">y</span><span class="p">,</span><span class="n">myHero</span><span class="p">.</span><span class="n">z</span><span class="p">,</span><span class="n">qRng</span><span class="p">,</span><span class="mh">0xFFFF0000</span><span class="p">)</span></div><div class='line' id='LC90'>	<span class="k">end</span> </div><div class='line' id='LC91'>	<span class="k">if</span> <span class="n">Config</span><span class="p">.</span><span class="n">Draw</span><span class="p">.</span><span class="n">draww</span> <span class="k">then</span></div><div class='line' id='LC92'>		<span class="n">DrawCircle</span><span class="p">(</span><span class="n">myHero</span><span class="p">.</span><span class="n">x</span><span class="p">,</span><span class="n">myHero</span><span class="p">.</span><span class="n">y</span><span class="p">,</span><span class="n">myHero</span><span class="p">.</span><span class="n">z</span><span class="p">,</span><span class="n">wRng</span><span class="p">,</span><span class="mh">0xFFFF0000</span><span class="p">)</span></div><div class='line' id='LC93'>	<span class="k">end</span></div><div class='line' id='LC94'><br/></div><div class='line' id='LC95'>	<span class="k">if</span> <span class="n">Config</span><span class="p">.</span><span class="n">Draw</span><span class="p">.</span><span class="n">drawe</span> <span class="k">then</span></div><div class='line' id='LC96'>		<span class="n">DrawCircle</span><span class="p">(</span><span class="n">myHero</span><span class="p">.</span><span class="n">x</span><span class="p">,</span><span class="n">myHero</span><span class="p">.</span><span class="n">y</span><span class="p">,</span><span class="n">myHero</span><span class="p">.</span><span class="n">z</span><span class="p">,</span><span class="n">eRng</span><span class="p">,</span><span class="mh">0xFFFF0000</span><span class="p">)</span></div><div class='line' id='LC97'>	<span class="k">end</span></div><div class='line' id='LC98'>	<span class="k">if</span> <span class="n">Config</span><span class="p">.</span><span class="n">Draw</span><span class="p">.</span><span class="n">drawr</span> <span class="k">then</span></div><div class='line' id='LC99'>		<span class="n">DrawCircle</span><span class="p">(</span><span class="n">myHero</span><span class="p">.</span><span class="n">x</span><span class="p">,</span><span class="n">myHero</span><span class="p">.</span><span class="n">y</span><span class="p">,</span><span class="n">myHero</span><span class="p">.</span><span class="n">z</span><span class="p">,</span><span class="n">rRng</span><span class="p">,</span><span class="mh">0xFFFF0000</span><span class="p">)</span></div><div class='line' id='LC100'>	<span class="k">end</span></div><div class='line' id='LC101'><span class="k">end</span></div><div class='line' id='LC102'><br/></div><div class='line' id='LC103'><span class="k">function</span> <span class="nf">OnProcessSpell</span><span class="p">(</span><span class="n">unit</span><span class="p">,</span><span class="n">spell</span><span class="p">)</span></div><div class='line' id='LC104'>	<span class="k">if</span> <span class="n">Config</span><span class="p">.</span><span class="n">bind</span><span class="p">.</span><span class="n">interrupt</span> <span class="k">then</span></div><div class='line' id='LC105'>		<span class="k">if</span> <span class="n">unit</span><span class="p">.</span><span class="n">type</span> <span class="o">==</span> <span class="s1">&#39;</span><span class="s">obj_AI_Hero&#39;</span> <span class="ow">and</span> <span class="n">unit</span><span class="p">.</span><span class="n">team</span> <span class="o">==</span> <span class="n">TEAM_ENEMY</span> <span class="ow">and</span> <span class="n">GetDistance</span><span class="p">(</span><span class="n">unit</span><span class="p">)</span> <span class="o">&lt;</span> <span class="n">rRng</span> <span class="k">then</span></div><div class='line' id='LC106'>		  <span class="kd">local</span> <span class="n">spellName</span> <span class="o">=</span> <span class="n">spell</span><span class="p">.</span><span class="n">name</span></div><div class='line' id='LC107'>			<span class="k">for</span> <span class="n">i</span> <span class="o">=</span> <span class="mi">1</span><span class="p">,</span> <span class="o">#</span><span class="n">champsToStun</span> <span class="k">do</span></div><div class='line' id='LC108'>				<span class="k">if</span> <span class="n">unit</span><span class="p">.</span><span class="n">charName</span> <span class="o">==</span> <span class="n">champsToStun</span><span class="p">[</span><span class="n">i</span><span class="p">].</span><span class="n">charName</span> <span class="ow">and</span> <span class="n">spellName</span> <span class="o">==</span> <span class="n">champsToStun</span><span class="p">[</span><span class="n">i</span><span class="p">].</span><span class="n">spellName</span> <span class="k">then</span></div><div class='line' id='LC109'>					<span class="k">if</span> <span class="n">champsToStun</span><span class="p">[</span><span class="n">i</span><span class="p">].</span><span class="n">important</span> <span class="o">==</span> <span class="mi">0</span> <span class="k">then</span></div><div class='line' id='LC110'>						<span class="k">if</span> <span class="n">R</span><span class="p">:</span><span class="n">IsReady</span><span class="p">()</span> <span class="ow">and</span> <span class="n">R</span><span class="p">:</span><span class="n">IsInRange</span><span class="p">(</span><span class="n">unit</span><span class="p">,</span><span class="n">myHero</span><span class="p">)</span> <span class="k">then</span></div><div class='line' id='LC111'>							<span class="n">R</span><span class="p">:</span><span class="n">Cast</span><span class="p">(</span><span class="n">unit</span><span class="p">)</span></div><div class='line' id='LC112'>						<span class="k">end</span></div><div class='line' id='LC113'>					<span class="k">else</span></div><div class='line' id='LC114'>						<span class="k">if</span> <span class="n">R</span><span class="p">:</span><span class="n">IsReady</span><span class="p">()</span> <span class="ow">and</span> <span class="n">R</span><span class="p">:</span><span class="n">IsInRange</span><span class="p">(</span><span class="n">unit</span><span class="p">,</span><span class="n">myHero</span><span class="p">)</span> <span class="k">then</span></div><div class='line' id='LC115'>							<span class="n">R</span><span class="p">:</span><span class="n">Cast</span><span class="p">(</span><span class="n">unit</span><span class="p">)</span></div><div class='line' id='LC116'>						<span class="k">end</span></div><div class='line' id='LC117'>					<span class="k">end</span></div><div class='line' id='LC118'>				<span class="k">end</span></div><div class='line' id='LC119'>			<span class="k">end</span></div><div class='line' id='LC120'>		<span class="k">end</span></div><div class='line' id='LC121'>	<span class="k">end</span></div><div class='line' id='LC122'><span class="k">end</span></div><div class='line' id='LC123'><br/></div><div class='line' id='LC124'><span class="k">function</span> <span class="nf">castQ</span><span class="p">(</span><span class="n">target</span><span class="p">)</span></div><div class='line' id='LC125'>	<span class="k">if</span> <span class="n">target</span> <span class="ow">and</span> <span class="n">Q</span><span class="p">:</span><span class="n">IsInRange</span><span class="p">(</span><span class="n">target</span><span class="p">)</span> <span class="ow">and</span> <span class="n">Q</span><span class="p">:</span><span class="n">IsReady</span><span class="p">()</span> <span class="k">then</span></div><div class='line' id='LC126'>		<span class="n">Q</span><span class="p">:</span><span class="n">Cast</span><span class="p">()</span></div><div class='line' id='LC127'>	<span class="k">end</span></div><div class='line' id='LC128'><span class="k">end</span></div><div class='line' id='LC129'><br/></div><div class='line' id='LC130'><span class="k">function</span> <span class="nf">castW</span><span class="p">(</span><span class="n">target</span><span class="p">,</span><span class="n">chance</span><span class="p">)</span></div><div class='line' id='LC131'>	<span class="k">if</span> <span class="n">target</span> <span class="ow">and</span> <span class="n">W</span><span class="p">:</span><span class="n">IsInRange</span><span class="p">(</span><span class="n">target</span><span class="p">)</span> <span class="ow">and</span> <span class="n">W</span><span class="p">:</span><span class="n">IsReady</span><span class="p">()</span> <span class="ow">and</span> <span class="n">Config</span><span class="p">.</span><span class="n">bind</span><span class="p">.</span><span class="n">useW</span> <span class="k">then</span></div><div class='line' id='LC132'>		<span class="n">wP</span><span class="p">,</span> <span class="n">wC</span> <span class="o">=</span> <span class="n">W</span><span class="p">:</span><span class="n">GetPrediction</span><span class="p">(</span><span class="n">target</span><span class="p">)</span></div><div class='line' id='LC133'>		<span class="k">if</span> <span class="n">wP</span> <span class="ow">and</span> <span class="n">wC</span> <span class="o">&gt;=</span> <span class="n">chance</span> <span class="k">then</span></div><div class='line' id='LC134'>			<span class="n">W</span><span class="p">:</span><span class="n">Cast</span><span class="p">(</span><span class="n">wP</span><span class="p">.</span><span class="n">x</span><span class="p">,</span><span class="n">wP</span><span class="p">.</span><span class="n">z</span><span class="p">)</span></div><div class='line' id='LC135'>		<span class="k">end</span></div><div class='line' id='LC136'>	<span class="k">end</span></div><div class='line' id='LC137'><span class="k">end</span></div><div class='line' id='LC138'><br/></div><div class='line' id='LC139'><span class="k">function</span> <span class="nf">castE</span><span class="p">(</span><span class="n">target</span><span class="p">)</span></div><div class='line' id='LC140'>	<span class="k">if</span> <span class="n">target</span> <span class="ow">and</span> <span class="n">E</span><span class="p">:</span><span class="n">IsInRange</span><span class="p">(</span><span class="n">target</span><span class="p">)</span> <span class="ow">and</span> <span class="n">E</span><span class="p">:</span><span class="n">IsReady</span><span class="p">()</span> <span class="k">then</span></div><div class='line' id='LC141'>		<span class="n">E</span><span class="p">:</span><span class="n">Cast</span><span class="p">(</span><span class="n">target</span><span class="p">)</span></div><div class='line' id='LC142'>	<span class="k">end</span></div><div class='line' id='LC143'><span class="k">end</span></div><div class='line' id='LC144'><br/></div><div class='line' id='LC145'><span class="k">function</span> <span class="nf">castR</span><span class="p">(</span><span class="n">target</span><span class="p">)</span></div><div class='line' id='LC146'>	<span class="k">if</span> <span class="n">target</span> <span class="ow">and</span> <span class="n">R</span><span class="p">:</span><span class="n">IsInRange</span><span class="p">(</span><span class="n">target</span><span class="p">)</span> <span class="ow">and</span> <span class="n">R</span><span class="p">:</span><span class="n">IsReady</span><span class="p">()</span> <span class="k">then</span></div><div class='line' id='LC147'>		<span class="n">R</span><span class="p">:</span><span class="n">Cast</span><span class="p">(</span><span class="n">target</span><span class="p">)</span></div><div class='line' id='LC148'>	<span class="k">end</span></div><div class='line' id='LC149'><span class="k">end</span></div><div class='line' id='LC150'><br/></div><div class='line' id='LC151'><span class="k">function</span> <span class="nf">castDFG</span><span class="p">(</span><span class="n">target</span><span class="p">)</span></div><div class='line' id='LC152'>	<span class="k">if</span> <span class="n">target</span> <span class="ow">and</span>  <span class="n">DFG</span><span class="p">:</span><span class="n">InRange</span><span class="p">(</span><span class="n">target</span><span class="p">)</span> <span class="ow">and</span> <span class="n">DFG</span><span class="p">:</span><span class="n">IsReady</span><span class="p">()</span> <span class="k">then</span></div><div class='line' id='LC153'>		<span class="n">DFG</span><span class="p">:</span><span class="n">Cast</span><span class="p">(</span><span class="n">target</span><span class="p">)</span></div><div class='line' id='LC154'>	<span class="k">end</span></div><div class='line' id='LC155'><span class="k">end</span></div><div class='line' id='LC156'><br/></div><div class='line' id='LC157'><span class="k">function</span> <span class="nf">active</span><span class="p">(</span><span class="n">target</span><span class="p">)</span></div><div class='line' id='LC158'>	<span class="k">if</span> <span class="n">target</span> <span class="k">then</span></div><div class='line' id='LC159'>		<span class="n">castQ</span><span class="p">(</span><span class="n">target</span><span class="p">)</span></div><div class='line' id='LC160'>		<span class="n">castW</span><span class="p">(</span><span class="n">target</span><span class="p">,</span><span class="mi">1</span><span class="p">)</span></div><div class='line' id='LC161'>		<span class="n">castDFG</span><span class="p">(</span><span class="n">target</span><span class="p">)</span></div><div class='line' id='LC162'>		<span class="n">castE</span><span class="p">(</span><span class="n">target</span><span class="p">)</span></div><div class='line' id='LC163'>		<span class="n">castR</span><span class="p">(</span><span class="n">target</span><span class="p">)</span></div><div class='line' id='LC164'>	<span class="k">end</span></div><div class='line' id='LC165'><span class="k">end</span></div><div class='line' id='LC166'><br/></div><div class='line' id='LC167'><span class="k">function</span> <span class="nf">harass</span><span class="p">(</span><span class="n">target</span><span class="p">)</span></div><div class='line' id='LC168'>	<span class="k">if</span> <span class="n">target</span> <span class="k">then</span></div><div class='line' id='LC169'>		<span class="n">castQ</span><span class="p">(</span><span class="n">target</span><span class="p">)</span></div><div class='line' id='LC170'>		<span class="n">castE</span><span class="p">(</span><span class="n">target</span><span class="p">)</span></div><div class='line' id='LC171'>	<span class="k">end</span></div><div class='line' id='LC172'><span class="k">end</span></div><div class='line' id='LC173'><br/></div><div class='line' id='LC174'><span class="k">function</span> <span class="nf">auto</span><span class="p">(</span><span class="n">target</span><span class="p">)</span></div><div class='line' id='LC175'>	<span class="k">if</span> <span class="n">target</span> <span class="k">then</span></div><div class='line' id='LC176'>		<span class="n">castE</span><span class="p">(</span><span class="n">target</span><span class="p">)</span></div><div class='line' id='LC177'>	<span class="k">end</span></div><div class='line' id='LC178'><span class="k">end</span></div><div class='line' id='LC179'><br/></div><div class='line' id='LC180'><br/></div></pre></div></td>
         </tr>
       </table>
  </div>

  </div>
</div>

<a href="#jump-to-line" rel="facebox[.linejump]" data-hotkey="l" class="js-jump-to-line" style="display:none">Jump to Line</a>
<div id="jump-to-line" style="display:none">
  <form accept-charset="UTF-8" class="js-jump-to-line-form">
    <input class="linejump-input js-jump-to-line-field" type="text" placeholder="Jump to line&hellip;" autofocus>
    <button type="submit" class="button">Go</button>
  </form>
</div>

        </div>

      </div><!-- /.repo-container -->
      <div class="modal-backdrop"></div>
    </div><!-- /.container -->
  </div><!-- /.site -->


    </div><!-- /.wrapper -->

      <div class="container">
  <div class="site-footer">
    <ul class="site-footer-links right">
      <li><a href="https://status.github.com/">Status</a></li>
      <li><a href="http://developer.github.com">API</a></li>
      <li><a href="http://training.github.com">Training</a></li>
      <li><a href="http://shop.github.com">Shop</a></li>
      <li><a href="/blog">Blog</a></li>
      <li><a href="/about">About</a></li>

    </ul>

    <a href="/">
      <span class="mega-octicon octicon-mark-github" title="GitHub"></span>
    </a>

    <ul class="site-footer-links">
      <li>&copy; 2014 <span title="0.07466s from github-fe132-cp1-prd.iad.github.net">GitHub</span>, Inc.</li>
        <li><a href="/site/terms">Terms</a></li>
        <li><a href="/site/privacy">Privacy</a></li>
        <li><a href="/security">Security</a></li>
        <li><a href="/contact">Contact</a></li>
    </ul>
  </div><!-- /.site-footer -->
</div><!-- /.container -->


    <div class="fullscreen-overlay js-fullscreen-overlay" id="fullscreen_overlay">
  <div class="fullscreen-container js-fullscreen-container">
    <div class="textarea-wrap">
      <textarea name="fullscreen-contents" id="fullscreen-contents" class="fullscreen-contents js-fullscreen-contents" placeholder="" data-suggester="fullscreen_suggester"></textarea>
    </div>
  </div>
  <div class="fullscreen-sidebar">
    <a href="#" class="exit-fullscreen js-exit-fullscreen tooltipped tooltipped-w" aria-label="Exit Zen Mode">
      <span class="mega-octicon octicon-screen-normal"></span>
    </a>
    <a href="#" class="theme-switcher js-theme-switcher tooltipped tooltipped-w"
      aria-label="Switch themes">
      <span class="octicon octicon-color-mode"></span>
    </a>
  </div>
</div>



    <div id="ajax-error-message" class="flash flash-error">
      <span class="octicon octicon-alert"></span>
      <a href="#" class="octicon octicon-x close js-ajax-error-dismiss" aria-label="Dismiss error"></a>
      Something went wrong with that request. Please try again.
    </div>


      <script crossorigin="anonymous" src="https://assets-cdn.github.com/assets/frameworks-df9e4beac80276ed3dfa56be0d97b536d0f5ee12.js" type="text/javascript"></script>
      <script async="async" crossorigin="anonymous" src="https://assets-cdn.github.com/assets/github-ac22781ae2feb62f0c47dcc6ed08996abfcd2fe7.js" type="text/javascript"></script>
      
      
        <script async src="https://www.google-analytics.com/analytics.js"></script>
  </body>
</html>

