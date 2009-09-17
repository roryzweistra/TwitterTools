package WebGUI::Macro::GetTweets; 

#-------------------------------------------------------------------
# Copyright Oqapi Software bv
#-------------------------------------------------------------------
# http://www.oqapi.nl                                  info@oqapi.nl
#-------------------------------------------------------------------

use strict;
use Net::Twitter::Lite;
use WebGUI::DateTime;
use Data::Dumper;

#-------------------------------------------------------------------
sub process {
	my $session 		= shift;
	my $template		= shift || "";
	my $username		= shift || "WUC2009"; # Fill in a username here for connecting to a default account
	my $password		= shift || "wuc2009"; # Fill in a password here for connecting to a default account
	my $messageCount	= shift || "10"; # The number of tweets, defaults to 10 

	# Test connection and throw error if any    
	my $twitterConnection;
    eval {
		$twitterConnection	= Net::Twitter::Lite->new(
			username	=> $username,
			password	=> $password
		);
	};
	
	if ( $@ ) {
		return "Error: " . $@;
	}
	
	# Get the tweets
	my $tweets = $twitterConnection->user_timeline( { count => $messageCount } ); 
	
	# Create template vars
	my @tweetsLoop;
	my $var		= {};
	
	foreach my $tweet ( @{$tweets} ) {
		
		push ( @tweetsLoop, {
			tweetId		=> $tweet->{ id			},
			date		=> $tweet->{ created_at	},
			source		=> $tweet->{ source 	},
			text 		=> $tweet->{ text		},
			userId		=> $tweet->{ user		}->{ id					},
			username	=> $tweet->{ user		}->{ screen_name		},
			name		=> $tweet->{ user 		}->{ name				},
			userPicUrl	=> $tweet->{ user		}->{ profile_image_url	},
			url			=> $tweet->{ user		}->{ url				},
		});
	}
	
	$var->{ 'tweetLoop' } = \@tweetsLoop;

	$session->log->error(Dumper($var));
	
    return;
}

1;