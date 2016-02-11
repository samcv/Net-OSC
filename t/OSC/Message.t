use v6;
use Test;
use lib 'lib';
use Net::OSC::Message;

plan 17;

#diag Net::OSC::Message.^methods.map({ $_.perl }).join: "\n";

my Net::OSC::Message $message;
lives-ok {
  $message .= new(
    :args<Hey 123 45.67>
  );
}, "Instantiate message";

diag "OSC type map:\n" ~ $message.type-map.map({ $_.join(' => ') ~ "\n"});

is $message.args, <Hey 123 45.67>, "get args";

is $message.type-string, 'sid', "build type-string";

ok $message.args('xyz', -987, -65.43), "Add args to message";

is $message.args, <Hey 123 45.67 xyz -987 -65.43>, "get args post addition";

is $message.type-string, 'sidsid', "build type-string post addition";


diag "package tests:";

is $message.pack-float32(12.375).perl, Buf.new(65, 70, 0, 0).perl, "pack 12.375";

my Buf $packed-message;
lives-ok  { $packed-message = $message.package; },                          "package message";

my Net::OSC::Message $post-pack-message;
lives-ok  { $post-pack-message .= unpackage($packed-message); },           "unpackage message";

is        $post-pack-message.path,         $message.path,         "post pack path";

for $post-pack-message.args.kv -> $k, $v {
  given $v -> $value {
    when $value ~~ Rat {
      ok        ($value > $message.args[$k]-0.1 and $value < $message.args[$k]+0.1),     "post pack Rat arg\[$k]";
    }
    default {
      is        $value,                    $message.args[$k],     "post pack arg\[$k]";
    }
  }
}

is        $post-pack-message.type-string,  $message.type-string,  "post pack type-string";