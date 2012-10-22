<?
require_once __DIR__.'/../vendor/autoload.php';

$app = new Silex\Application();
$app['debug'] = true;

$app->register(new Silex\Provider\UrlGeneratorServiceProvider());
$app->register(new Silex\Provider\TwigServiceProvider(), array(
    'twig.path' => __DIR__.'/../src/views',
));


// INDEX
$index = function () use ($app) {
    $data['page'] = "index";
    return $app['twig']->render('page/home.html.twig', $data);
};
$app->get('/', $index)
    ->bind('index');

$app->run();