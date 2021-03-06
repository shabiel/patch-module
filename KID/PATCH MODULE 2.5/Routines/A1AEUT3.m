A1AEUT3 ;ven/lgc,jli-unit tests for the patch module ;2014-09-15T21:09
 ;;2.5;PATCH MODULE;;Jun 13, 2015
 ;;Submitted to OSEHRA 3 June 2015 by the VISTA Expertise Network
 ;;Licensed under the terms of the Apache License, version 2.0
 ;
 ;
 ;primary change history
 ;2014-03-28: version 2.4 released
 ;
 ; CHANGE: (VEN/LGC) Corrected calls to Post Install
 ;        The Post install was moved out of the A1AEUTL
 ;        routine and placed in the A1AE2POS routine
 ;        now designated as the post install repository
 ;
START I $T(^%ut)="" W !,"*** UNIT TEST NOT INSTALLED ***" Q
 D EN^%ut($T(+0),1)
 Q
 ;
STARTUP L +^A1AE(11007.1):1 I '$T D  Q
 .  W !,"*** COULD NOT GET LOCK.  TRY LATER ***"
 ;
SHUTDOWN L -^A1AE(11007.1) Q
 ;
 ; Unit Test setting all PRIMARY to 0
 ;   1. Save the IEN of entry now set as PRIMARY
 ;   2. Run A1AEP0
 ;   3. Find IEN set to 1 (shouldn't be any)
 ;   4. Return original PRIMARY setting
 ;   5. Run Unit Test
 ;
UTP0 N A1AEI,UTOIEN,UTPOST
 ; Save IEN of entry now set as PRIMARY?
 S UTOIEN=$$UTPRIEN
 ; If no Stream was set to PRIMARY, we must set one 
 ;  or we are unable to check that clearing all PRIMARY works
 S:'UTOIEN $P(^A1AE(11007.1,1,0),U,2)=1
 ; Call should set all PRIMARY to 0
 D A1AEP1A^A1AE2POS
 ; See if all PRIMARY are 0
 S UTPOST=$$UTPRIEN
 ;
 ; Return PRIMARY to original value
 S:UTOIEN $P(^A1AE(11007.1,UTOIEN,0),U,2)=1
 D CHKEQ^%ut(0,UTPOST,"Set all PRIMARY to 0 FAILED")
 ;
 ; Now that we have returned PRIMARY to original setting
 ;   clean up everything by rebuilding all cross-references
 N DIK,DA
 S DIK(1)=".02",DIK="^A1AE(11007.1,"
 D ENALL2^DIK
 D ENALL^DIK
 Q
 ;
 ;
 ; Note in Unit Testing of setting PRIMARY? to match that
 ;   assigned for specific FORUM Domains, that a non-FORUM
 ;   site will test only that an incorrect PRIMARY? will
 ;   not be set.
 ;   The test in a FORUM Domain site will test whether
 ;   the PRIMARY? is set, AND set correctly
 ; Logic for Post Install setting or PRIMARY worked correctly
 ;   UTDOM = MAIL PARAMETERS not have FORUM domain = NO PRIMARY
 ;   UTDOM = NOT A FORUM domain = NO PRIMARY
 ;   UTDOM = FORUM.XXX.YYY
 ;       A FORUM DOMAIN entry = MAIL PARAMETER DOMAIN = is PRIMARY
 ;       No FORUM DOMAIN entry = MAIL PARAMETER DOMAIN = NO PRIMARY
 ;
UTPR N A1AEI,UTDOM,UTOIEN,UTPOST,X
 S UTDOM=$$GET1^DIQ(4.3,"1,",.01)
 ; Save present PRIMARY patch stream IEN - if one set
 S UTOIEN=$$UTPRIEN
 ; If a Patch Stream PRIMARY? is set to YES, set to NO
 S:UTOIEN $P(^A1AE(11007.1,UTOIEN,0),U,2)=0
 ; Run code to set PRIMARY? according to FORUM DOMAIN entry
 D A1AEP1B^A1AE2POS
 ; Get the IEN of the entry having PRIMARY? set to yes now
 ; Note that if no FORUM DOMAIN entry is filled into
 ;   an entry in DHCP PATCH STREAM then all entries
 ;   remain CORRECTLY at PRIMARY=0
 S UTPOST=$$UTPRIEN
 S X=1
 ; If all PRIMARY are 0, and
 ;    a) and MAIL DOMAIN not contain "FORUM" --- correct 
 ;    b) and no FORUM DOMAIN fields set in 11007.1 --- correct
 ; If there is a PRIMARY set then correct if,
 ;    a) the mail domain (UTDOM) contains "FORUM"
 ;    b) and, the FORUM DOMAIN for this entry set to PRIMARY
 ;            matches the mail domain
 I 'UTPOST,$P($G(UTDOM),".")'["FORUM" S X=0
 I 'UTPOST,'$D(^A1AE(11007.1,"AFORUM")) S X=0
 I $P(UTDOM,".")["FORUM",UTDOM=$$GET1^DIQ(11007.1,UTPOST_",",.07) D
 . S X=0
 D CHKEQ^%ut(0,X,"Set FORUM SITE PRIMARY to 1 FAILED")
 ; Put settings back as they were, even if incorrect
 I UTOIEN'=UTPOST D
 .  S $P(^A1AE(11007.1,UTPOST,0),U,2)=0
 .  S $P(^A1AE(11007.1,UTOIEN,0),U,2)=1
 N DIK,DA
 S DIK(1)=".02",DIK="^A1AE(11007.1,"
 D ENALL2^DIK
 D ENALL^DIK
 Q
 ;
 ;
 ; Unit Testing for subroutine that sets all SUBSCRIPTION [#.06]
 ;   to 0 [NO], then sets SUBSCRIPTION to YES for the FOIA VISTA
 ;   Stream.
 ; Rather than correct a site's entries if they are set wrong
 ;   we will first save off their present SUBSCRIPTION entry
 ;   in the DHCP PATCH STREAM [#11007.1] file so we might 
 ;   set it back after our test.
 ; Logic for test
 ;   1. Save off IEN for entry in DHCP PATCH STREAM [#11007.1]
 ;       SUBSCRIPTION presently set to 1 [YES]
 ;   2. Run A1AEP1C^A1AE2POS in the Post Install routine
 ;      which should set SUBSCRIPTION to 0, then set
 ;      the FOIA VISTA site to SUBSCRIPTION
 ;   3. Set the IEN for Stream SUBSCRIPTION back to original
 ;   4. Run Unit Test code 
 ;
UTS0 N A1AEI,UTOIEN,UTPOST
 ; Save off stream now set to SUBSCRIPTION
 S UTOIEN=$$UTSUBS
 ; If no Stream was set to SUBSCRIPTION, we must set one
 ;  or we are unable to check that clearing all SUBSCRIPTION works
 I 'UTOIEN S A1AEI=$O(^A1AE(11007.1,"A"),-1) D
 .  S $P(^A1AE(11007.1,A1AEI,0),U,6)=1
 ; Call subroutine in Post Install routine that sets
 ;   SUBSCRIPTION to the FOIA VISTA entry
 D A1AEP1C^A1AE2POS
 ; See what entry in 11007.1 file is now set to SUBSCRIPTION
 S UTPOST=$$UTSUBS
 ; Return SUBSCRIPTION to original value
 I UTOIEN,UTOIEN'=UTPOST D
 . S $P(^A1AE(11007.1,UTPOST,0),U,6)=0
 . S $P(^A1AE(11007.1,UTOIEN,0),U,6)=1
 S X=1
 I UTPOST,$P(^A1AE(11007.1,UTPOST,0),U)="FOIA VISTA" S X=0
 D CHKEQ^%ut(0,X,"Set SEQUENCE appropriate for FORUM DOMAIN FAILED")
 N DIK,DA
 S DIK(1)=".06",DIK="^A1AE(11007.1,"
 D ENALL2^DIK
 D ENALL^DIK
 Q
 ;
 ;
 ;
 ; Function to return IEN in DHCP PATCH STREAM [#11007.1]
 ;   entry having PRIMARY? [#.02] field set
UTPRIEN() N A1AEI,UTPRIM S (A1AEI,UTPRIM)=0
 F  S A1AEI=$O(^A1AE(11007.1,A1AEI)) Q:'A1AEI  D
 .  I $P(^A1AE(11007.1,A1AEI,0),U,2) S UTPRIM=A1AEI
 Q UTPRIM
 ;
 ; Function to return IEN in DHCP PATCH STREAM [#11007.1]
 ;   entry having SUBSCRIPTION [#.03] field set
UTSUBS() N UTSUBS S (A1AEI,UTSUBS)=0
 F  S A1AEI=$O(^A1AE(11007.1,A1AEI)) Q:'A1AEI  D
 .  I $P(^A1AE(11007.1,A1AEI,0),U,6) S UTSUBS=A1AEI
 Q UTSUBS
 ;
XTENT ;
 ;;UTP0;Testing setting of all PRIMARY? to NO in 11007.1
 ;;UTPR;Testing setting PRIMARY? to yes if FORUM site
 ;;UTS0;Testing setting of SUBSCRIPTION to FOIA VISTA
 Q
 ;
EOR ; end of routine A1AEUT3
