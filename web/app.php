<?
require_once __DIR__.'/../vendor/autoload.php';

setlocale(LC_ALL, 'fr_CA.UTF-8');

$app = new Silex\Application();
$app['debug'] = true;

$app->register(new Silex\Provider\UrlGeneratorServiceProvider());
$app->register(new Silex\Provider\TwigServiceProvider(), array(
    'twig.path' => __DIR__.'/../src/views',
));

$app->register(new Silex\Provider\DoctrineServiceProvider(), array(
    'db.options' => array(
        'driver'   => 'pdo_sqlite',
        'path'     => __DIR__.'/../db/app.db',
    ),
));

function dateTime($dateTime, $format) {
    if ($dateTime instanceof \DateTime) {
        $dateTime = $dateTime->getTimestamp();
    }

    return strftime($format, $dateTime);
}

$app['twig'] = $app->share($app->extend('twig', function($twig, $app) {
    $twig->addFilter('dateTime', new \Twig_Filter_Function('dateTime'));

    return $twig;
}));


// INDEX
$index = function ($day = null, $slug = null, $id = null) use ($app) {
    date_default_timezone_set('GMT');
    $sql = "SELECT * FROM room ORDER BY id ASC";
    $rooms = $app['db']->fetchAll($sql);

    $sql = "SELECT * FROM speaker ORDER BY id ASC";
    $query = $app['db']->executeQuery($sql);
    $speakers = array();
    while ($speaker = $query->fetch(\PDO::FETCH_ASSOC)) {
        $speakers[$speaker["id"]] = $speaker;
    }

    $sql = "SELECT * FROM sponsor ORDER BY id ASC";
    $query = $app['db']->executeQuery($sql);
    $sponsors = array();
    while ($sponsor = $query->fetch(\PDO::FETCH_ASSOC)) {
        $sponsors[$sponsor["id"]] = $sponsor;
    }

    $sql = "SELECT * FROM session ORDER BY start ASC";
    $sessionsTmp = $app['db']->fetchAll($sql);

    $sessions = array();
    $block = array();
    $lines = array();
    $firstLine = "";
    $start = 0;
    $end = 0;
    foreach ($sessionsTmp as $session) {
        $dateTime = new DateTime();
        $dateTime->setTimestamp($session["start"]);

        $session["line"] = ltrim($dateTime->format("H\hi"), "0");
        $session["duration"] = ($session["end"] - $session["start"]) / 60;
        if (is_null($session["room_id"])) {
            $session["room_id"] = 0;
        }

        if (!isset($sessions[$dateTime->format("dmY")])) {
            $day = new DateTime();
            $day->setTimestamp($session["start"]);
            $day->setTime(0, 0);
            $lines[$dateTime->format("dmY")] = array();
            $sessions[$dateTime->format("dmY")] = array("day" => $day->getTimestamp(), "blocks" => array());
        }
        if (!in_array($session["line"], $lines[$dateTime->format("dmY")])) {
            $lines[$dateTime->format("dmY")][] = $session["line"];
        }

        // Verify if we have a new block
        if ($session["break"] == 1 || $session["row"] == 1) {
            // New block

            if (!empty($block)) {
                // Save block
                $sessions[$dateTime->format("dmY")]["blocks"][] = array(
                    "size" => ($end - $start) / 60,
                    "line" => $firstLine,
                    "list" => $block,
                );
            }

            // Add break/row
            $sessions[$dateTime->format("dmY")]["blocks"][] = array(
                "size" => $session["duration"],
                "session" => $session,
            );
            $block = array();
            $start = 0;
            $end = 0;
            continue;
        }

        if (empty($block)) {
            $firstLine = $session["line"];
        }

        if (!isset($block[$session["room_id"]])) {
            $block[$session["room_id"]] = array();
        }

        if ($start == 0) {
            $start = $session["start"];
        }
        $start = min($start, $session["start"]);
        $end = max($end, $session["end"]);
        $block[$session["room_id"]][] = $session;
    }
    return $app['twig']->render('home/index.html.twig', array(
        "page" => "index",
        "speakers" => $speakers,
        "sponsors" => $sponsors,
        "rooms" => $rooms,
        "lines" => $lines,
        "sessions" => $sessions
        ));
};
$app->get('/', $index)
    ->bind('index');

$app->get('/horaire/{day}/{slug}-{id}', function ($day = null, $slug = null, $id = null) use ($app) {
    $sessionId = (int) $id;
    $sql = "SELECT * FROM session WHERE id = ?";
    $session = $app['db']->fetchAssoc($sql, array($sessionId));
    var_dump($session);
    if ($session) {
      return $app['twig']->render('conference/index.html.twig', $session);
    } else {
      $app->abort(404);
    }
  
})->bind('showSchedule');


$app->error(function (\Exception $e, $code) use ($app){ 
  if (404 == $code) { 
    return $app['twig']->render('404.html.twig');
  } 
});

$app->run();