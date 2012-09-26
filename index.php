<!DOCTYPE html>
<html lang="fr">
  <head>
    <meta charset="utf-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <meta name="viewport" content="width=device-width, initial-scale=1"/>
    <meta name="description" content="Le Web À Québec c'est trois jours de rencontres par et pour les gens qui imaginent le web." />

    <title>Web à Québec</title>

    <link rel="author" href="/humans.txt"/>
    <link rel="stylesheet" href="/assets/stylesheets/global.css">

    <!--[if lte IE 9]><script src="http://html5shiv.googlecode.com/svn/trunk/html5.js"></script><![endif]-->

    <script type="text/javascript">
      var _gaq = _gaq || [];
          _gaq.push(['_setAccount', 'UA-20043510-1'],
                    ['_trackPageview']),
                    ['ix_setAccount', 'UA-25106796-1'],
                    ['ix_setDomainName', 'webaquebec.org'],
                    ['ix_setAllowHash', false],
                    ['ix_setAllowLinker', true],
                    ['ix_trackPageview'],);

      (function() { var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true; ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js'; var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s); })(); </script>
    </script>
  </head>

  <body style="background-image:url('/assets/images/backgrounds/bg-waq<?= rand(1,4); ?>.jpg')">

    <div id="big-container">
      <div id="wrapper">
        <div class="width">
          <div class="group">
            <nav id="meta-nav">
              <p class="uppercase">Suivez-nous : </p>
              <ul>
                <li>
                  <a href="https://twitter.com/webaquebec" title="Lien vers le compte Twitter du Web À Québec">
                    <img src="/assets/images/layout/ico-twitter.png" alt="Icône Twitter">
                    <span class="shy">Twitter</span>
                  </a>
                </li>

                <li id="facebook">
                  <a href="http://www.facebook.com/webaquebec" title="Lien vers le compte Facebook du Web À Québec">
                    <img src="/assets/images/layout/ico-facebook.png" alt="Icône Facebook">
                    <span class="shy">Facebook</span>
                  </a>
                </li>
              </ul>
            </nav>
          </div>

          <header id="header">
            <div>
              <section id="event-details">
                <h1 class="shy">Web À Québec</h1>
                <img src="/assets/images/layout/logo-webaquebec.png" alt="Logo - Web À Québec">

                <span id="dates">du <time datetime="2013-02-20">20 <span class="uppercase">au</span> <time datetime="2013-02-22">22</time> février 2013</span>
                <span id="location">Espace 400<sup>e</sup> Bell, Québec</span>
              </section>

              <h2>Trois jours de rencontres par et pour les gens qui imaginent le web.</h2>
            </div>

            <div>
              <h1 class="uppercase">Le WAQ est enfin de retour !</h1>

              <section id="register">
                <span id="until-date" class="uppercase">Jusqu'au 19 octobre</span>
                <span class="uppercase">Tarif «à l'aveuglette»</span>

                <div id="carey-price">
                  <span id="current-price">295<sup class="currency">$</sup></span>
                  <span id="price">
                    595<sup class="curreny">$</sup>
                    <span id="red-line"></span>
                  </span>

                  <a href="http://webaquebec2013.eventbrite.ca/" class="subscribe uppercase">Inscription</a>
                </div>

                <p><strong>Vous connaissez un sujet intéressant?</strong> Vous désirez être conférencier pour le WAQ 2013? L'équipe de la programmation du Web à Québec aimerait en savoir davantage!</p>

                <section id="suggest-a-talk">
                  <a href="https://docs.google.com/spreadsheet/viewform?fromEmail=true&amp;formkey=dGJ3RmRFRXBYRUhGbG1mZFAxbUVTWmc6MQ " class="uppercase">Proposez une présentation</a>
                </section>
              </section>
            </div>
          </header>
        </div>
      </div>
    </div>

    <p id="copyright">Crédit photo : Marc-Antoine Jean</p>
  </body>
</html>