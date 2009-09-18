package WebGUI::Macro::GetTweets; 

#-------------------------------------------------------------------
# Copyright Oqapi Software bv
#-------------------------------------------------------------------
# http://www.oqapi.nl                                  info@oqapi.nl
#-------------------------------------------------------------------

use strict;
use WebGUI::Asset::Template;
use Net::Twitter::Lite;

#-------------------------------------------------------------------
sub process {
	my $session 		= shift;
	my $templateId		= shift || "";
	my $username		= shift || ""; 		# Fill in a username here for connecting to a default account
	my $password		= shift || ""; 		# Fill in a password here for connecting to a default account
	my $messageCount	= shift || "10";	# The number of tweets, defaults to 10 

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
	
	unless ( $tweets ) {
		return "No Tweets were found.";
	}
	
	# Create template vars
	my @tweetsLoop;
	my $var = {};
	
	foreach my $tweet ( @{ $tweets } ) {
		
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
		} );
	}
	
	$var->{ 'tweetLoop' } = \@tweetsLoop;
	
	return WebGUI::Asset::Template->new( $session, $templateId)->process( $var );
}

1;