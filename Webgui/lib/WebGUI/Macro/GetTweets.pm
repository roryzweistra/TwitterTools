package WebGUI::Macro::GetTweets; 

#-------------------------------------------------------------------
# Copyright Oqapi Software bv
#-------------------------------------------------------------------
# http://www.oqapi.nl                                  info@oqapi.nl
#-------------------------------------------------------------------

use strict;
use WebGUI::Asset::Template;
use Net::Twitter::Lite;

=head1 NAME 

Package WebGUI::Macro::GetTweets
 
=head1 DESCRIPTION
 
Macro for returning status updates from a twitter account.
 
=head2 process ( templateId, username, password, messageCount )
 
=head3 templateId
 
The GUID of a template that is used for displaying the tweets on a page

=head3 username

The username of the twitter account. Instead of passing it to the Macro you can also
set the username in the Macro code itself.

=head3 password

The password of the twitter account. Instead of passing it to the Macro you can also
set the password in the Macro code itself.

=head3 messageCount

The number of tweets to be shown on the page. Defaults to 10.

=cut


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
			source		=> $tweet->{ source		},
			text 		=> $tweet->{ text		},
			userId		=> $tweet->{ user		}->{ id					},
			username	=> $tweet->{ user		}->{ screen_name		},
			name		=> $tweet->{ user 		}->{ name				},
			userPicUrl	=> $tweet->{ user		}->{ profile_image_url	},
			url			=> $tweet->{ user		}->{ url				},
		} );
	}
	
	$var->{ 'tweetLoop' } = \@tweetsLoop;
	
	my $template = WebGUI::Asset::Template->new( $session, $templateId );
	
	if ( $template ) {
		return $template->process( $var );
	}
	else {
		return "Template could not be instanciated.";
	}
	
}

1;