<?php
namespace BossEdu\Controller;

use BombArea\SSO\Client;
use BombArea\SSO\LoggedClient;
use BossEdu\Model\SomeoneQuery;
use BossEdu\Util\Util;
use Jacwright\RestServer\RestException;
use Mailgun\Mailgun;

class AuthCtrl
{
    /**
     * @var Client
     */
    private static $client;

    /**
     * @return Client
     */
    public static function getClient()
    {
        if (!self::$client) new Client("http://auth.localhost/controller", "client", "asd123");

        return self::$client;
    }

    public static function check()
    {
        if (!isset($_COOKIE[self::getCookieName()])) return false;

        return true;
    }

    private static function buildLoggedClient()
    {
        if(!self::check()) throw new \Exception("You aren't logged");

        return new LoggedClient(self::getClient(), $_COOKIE[self::getCookieName()]);
    }

    /**
     * @url POST /login
     */
    public function login()
    {
        $postData = json_decode(file_get_contents("php://input"), true);
        $postData["persist"] = $postData["persist"] ?? false;

        try {
            $loggedClient = self::getClient()->login($postData["email"], $postData["password"]);
            self::setCookie($loggedClient->getSessionToken(), $postData["persist"]);

            $loggedClient->setSessionData(["persist" => $postData["persist"]]);
        } catch (\Exception $ex) {
            throw new RestException(401, $ex->getMessage());
        }
    }

    /**
     * @url GET /logout
     * @url POST /logout
     */
    public function logout()
    {
        $loggedClient = new LoggedClient(self::getClient(), $_COOKIE[self::getCookieName()]);

        try {
            $loggedClient->logout();
            self::deleteCookie();
        } catch (\Exception $ex) {
            throw new RestException(401, $ex->getMessage());
        }
    }

    /**
     * @url POST /recover-password
     */
    public function recoverPassword()
    {
        $email = Util::getPostContents("lower")["email"];

        $user = SomeoneQuery::create()
            ->findOneByEmail($email);

        if ($user) {
            $mgClient = new Mailgun("key-c34a8cf7dc6291c18df4fd0c92d3e6ba");
            $domain = "sandboxa45ec9d3f56c49078aad139e56984298.mailgun.org";

            $mgClient->sendMessage("$domain",
                [ "from"    => "Mirage <postmaster@sandboxa45ec9d3f56c49078aad139e56984298.mailgun.org>",
                    "to"      => $user->getEmail(),
                    "subject" => "Recuperação de Senha",
                    "text"    => $user->getPassword()
                ]
            );
        } else {
            throw new RestException(401, "Unauthorized");
        }
    }

    public function getSession()
    {
        $loggedUser = self::buildLoggedClient();
        return $loggedUser->getSessionData();
    }

    public function setSession($values)
    {
        $loggedUser = self::buildLoggedClient();
        return $loggedUser->setSessionData($values);
    }

    private static function setCookie($value, $persist = false)
    {
        $ttl = 0;

        if ($persist) $ttl = time() + 3600 * 24 * 60;

        setcookie(self::getCookieName(), $value, $ttl, "/");
    }

    private static function deleteCookie()
    {
        setcookie(self::getCookieName(), "", -3600, "/");
    }

    private static function renewCookie()
    {
        setcookie(self::getCookieName(), $_COOKIE[self::getCookieName()], time() + 3600 * 24 * 60, "/");
    }

    private static function getCookieName()
    {
        return "sso_client_token";
    }
}
