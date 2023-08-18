import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.1
import de.webappjung 1.0

Page {
    id: page
    title: qsTr("About")
    anchors.fill: parent
    anchors.margins: 5

    ScrollView {
        id: scrollView
        anchors.fill: parent
        contentWidth: -1

        GridLayout {
            id: grid
            columns: 1
            width: page.width // Important

            Label {
                id: aboutCloudLogOffline
                padding: 5
                wrapMode: Text.WordWrap
                //wrapMode: Text.Wrap
                width: scrollView.width
                Layout.maximumWidth: scrollView.width

                text: "<h1>About</h1>
CloudLogApp is developed by Matthias Jung (DL9MJ, AJ9MJ) and hosted by DARC e.V.<br>The repeater list is provided by https://hearham.com<br>"
                color: "white"
            }

            Label {
                id: versionLabel
                padding: 5
                text: "Version: " + AppInfo.version + " Database: " + database.getDatabaseVersion() + "<br>"
            }

            Label {
                id: privacyDrawer
                padding: 5
                wrapMode: Text.WordWrap
                //wrapMode: Text.Wrap
                width: scrollView.width
                Layout.maximumWidth: scrollView.width
                // https://gist.github.com/alex-spataru/ee5e74f82a72a0a2e446766a77c43665<br>

                text: "<h1>Privacy</h1>
Using the CloudLogOffline App: Description and scope of data processing<br>
<h2>Data</h2>
In our app, all data is stored exclusively locally on your device. We have, just like everyone else, no access to your data.<br>
<h2>Cloud Storage</h2>
In the app, you can set up a connection to cloud storage to store data in the cloud. By default, no cloud connection is preset. If a cloud connection is set up in the app, the data vault is only uploaded to the cloud storage by your explicit action (click Export). An automatic upload never takes place. If a cloud storage is used, the operator of the cloud providers is their sole contractual partner in this respect. Accordingly, the data protection guidelines of the cloud operator apply exclusively.<br>
<h2>QRZ.com</h2>
The connection to the XML service of QRZ.com is always handled directly and without detours between your device and the respective QRZ.com. There are never any intermediary servers involved by us. The transmission is always encrypted using the encryption and security procedures used by QRZ.com. The privacy policy of QRZ.com can be found <a href=\"https://www.qrz.com/page/privacy.html\">here</a>.<br>
<h2>Transmission of statistical usage data</h2>
Our apps do not transmit statistical usage data to a server system of the Web & App Dr.-Ing. Matthias Jung.<br>
<h2>Purchase of the App</h2>
If you purchase the app, the operator of the app shop is your contractual partner. The handling of the sale is therefore solely subject to the privacy policy of the app shop operator. All personal data provided to us by the app shop operator for the purpose of processing the purchase are used by us exclusively for the purpose of fulfilling the task and are not passed on to third parties.<br>
               "
                color: "white"
            }
            Label {
                id: aboutDrawer
                padding: 5
                wrapMode: Text.WordWrap
                //wrapMode: Text.Wrap
                width: scrollView.width
                Layout.maximumWidth: scrollView.width
                // https://gist.github.com/alex-spataru/ee5e74f82a72a0a2e446766a77c43665<br>

                text: "<h1>Used Open Source Librarys</h1>
<hr>
<h2>QML Material Drawer by Alex-Spataru</h2><br>
<i>
THE FUCK YOU WANT TO PUBLIC LICENSE<br>
Version 2, December 2004<br><br>

Copyright (C) 2004 Sam Hocevar sam@hocevar.net <br><br>

Everyone is permitted to copy and distribute verbatim or modified copies of this license document, and changing it is allowed as long as the name is changed.<br><br>

DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION<br><br>

0. You just DO WHAT THE FUCK YOU WANT TO.<br>
</i>
               "
                color: "white"
            }

            Label {
                id: aboutQt
                padding: 5
                wrapMode: Text.WordWrap
                //wrapMode: Text.Wrap
                width: scrollView.width
                Layout.maximumWidth: scrollView.width
                // https://gist.github.com/alex-spataru/ee5e74f82a72a0a2e446766a77c43665<br>

                text: "<h2>Qt</h2><br>
<i>
                 GNU LESSER GENERAL PUBLIC LICENSE<br>
                       Version 3, 29 June 2007<br><br>

 Copyright (C) 2007 Free Software Foundation, Inc. <http://fsf.org/>
 Everyone is permitted to copy and distribute verbatim copies
 of this license document, but changing it is not allowed.<br><br>

  This version of the GNU Lesser General Public License incorporates
the terms and conditions of version 3 of the GNU General Public
License, supplemented by the additional permissions listed below.<br><br>

  0. Additional Definitions.<br><br>

  As used herein, \"this License\" refers to version 3 of the GNU Lesser
General Public License, and the \"GNU GPL\" refers to version 3 of the GNU
General Public License.<br><br>

  \"The Library\" refers to a covered work governed by this License,
other than an Application or a Combined Work as defined below.<br><br>

  An \"Application\" is any work that makes use of an interface provided
by the Library, but which is not otherwise based on the Library.
Defining a subclass of a class defined by the Library is deemed a mode
of using an interface provided by the Library.<br><br>

  A \"Combined Work\" is a work produced by combining or linking an
Application with the Library.  The particular version of the Library
with which the Combined Work was made is also called the \"Linked
Version\".<br><br>

  The \"Minimal Corresponding Source\" for a Combined Work means the
Corresponding Source for the Combined Work, excluding any source code
for portions of the Combined Work that, considered in isolation, are
based on the Application, and not on the Linked Version.<br><br>

  The \"Corresponding Application Code\" for a Combined Work means the
object code and/or source code for the Application, including any data
and utility programs needed for reproducing the Combined Work from the
Application, but excluding the System Libraries of the Combined Work.<br><br>

  1. Exception to Section 3 of the GNU GPL.<br><br>

  You may convey a covered work under sections 3 and 4 of this License
without being bound by section 3 of the GNU GPL.<br><br>

  2. Conveying Modified Versions.<br><br>

  If you modify a copy of the Library, and, in your modifications, a
facility refers to a function or data to be supplied by an Application
that uses the facility (other than as an argument passed when the
facility is invoked), then you may convey a copy of the modified
version:<br><br>

   a) under this License, provided that you make a good faith effort to
   ensure that, in the event an Application does not supply the
   function or data, the facility still operates, and performs
   whatever part of its purpose remains meaningful, or<br><br>

   b) under the GNU GPL, with none of the additional permissions of
   this License applicable to that copy.<br><br>

  3. Object Code Incorporating Material from Library Header Files.<br><br>

  The object code form of an Application may incorporate material from
a header file that is part of the Library.  You may convey such object
code under terms of your choice, provided that, if the incorporated
material is not limited to numerical parameters, data structure
layouts and accessors, or small macros, inline functions and templates
(ten or fewer lines in length), you do both of the following:<br><br>

   a) Give prominent notice with each copy of the object code that the
   Library is used in it and that the Library and its use are
   covered by this License.<br><br>

   b) Accompany the object code with a copy of the GNU GPL and this license
   document.<br><br>

  4. Combined Works.<br><br>

  You may convey a Combined Work under terms of your choice that,
taken together, effectively do not restrict modification of the
portions of the Library contained in the Combined Work and reverse
engineering for debugging such modifications, if you also do each of
the following:<br><br>

   a) Give prominent notice with each copy of the Combined Work that
   the Library is used in it and that the Library and its use are
   covered by this License.<br><br>

   b) Accompany the Combined Work with a copy of the GNU GPL and this license
   document.<br><br>

   c) For a Combined Work that displays copyright notices during
   execution, include the copyright notice for the Library among
   these notices, as well as a reference directing the user to the
   copies of the GNU GPL and this license document.<br><br>

   d) Do one of the following:<br><br>

       0) Convey the Minimal Corresponding Source under the terms of this
       License, and the Corresponding Application Code in a form
       suitable for, and under terms that permit, the user to
       recombine or relink the Application with a modified version of
       the Linked Version to produce a modified Combined Work, in the
       manner specified by section 6 of the GNU GPL for conveying
       Corresponding Source.<br><br>

       1) Use a suitable shared library mechanism for linking with the
       Library.  A suitable mechanism is one that (a) uses at run time
       a copy of the Library already present on the user's computer
       system, and (b) will operate properly with a modified version
       of the Library that is interface-compatible with the Linked
       Version.<br><br>

   e) Provide Installation Information, but only if you would otherwise
   be required to provide such information under section 6 of the
   GNU GPL, and only to the extent that such information is
   necessary to install and execute a modified version of the
   Combined Work produced by recombining or relinking the
   Application with a modified version of the Linked Version. (If
   you use option 4d0, the Installation Information must accompany
   the Minimal Corresponding Source and Corresponding Application
   Code. If you use option 4d1, you must provide the Installation
   Information in the manner specified by section 6 of the GNU GPL
   for conveying Corresponding Source.)<br><br>

  5. Combined Libraries.<br><br>

  You may place library facilities that are a work based on the
Library side by side in a single library together with other library
facilities that are not Applications and are not covered by this
License, and convey such a combined library under terms of your
choice, if you do both of the following:<br><br>

   a) Accompany the combined library with a copy of the same work based
   on the Library, uncombined with any other library facilities,
   conveyed under the terms of this License.<br><br>

   b) Give prominent notice with the combined library that part of it
   is a work based on the Library, and explaining where to find the
   accompanying uncombined form of the same work.<br><br>

  6. Revised Versions of the GNU Lesser General Public License.<br><br>

  The Free Software Foundation may publish revised and/or new versions
of the GNU Lesser General Public License from time to time. Such new
versions will be similar in spirit to the present version, but may
differ in detail to address new problems or concerns.<br><br>

  Each version is given a distinguishing version number. If the
Library as you received it specifies that a certain numbered version
of the GNU Lesser General Public License \"or any later version\"
applies to it, you have the option of following the terms and
conditions either of that published version or of any later version
published by the Free Software Foundation. If the Library as you
received it does not specify a version number of the GNU Lesser
General Public License, you may choose any version of the GNU Lesser
General Public License ever published by the Free Software Foundation.<br><br>

  If the Library as you received it specifies that a proxy can decide
whether future versions of the GNU Lesser General Public License shall
apply, that proxy's public statement of acceptance of any version is
permanent authorization for you to choose that version for the
Library.<br><br>
</i>
               "
                color: "white"
            }

            Label {
                id: aboutSSL
                padding: 5
                wrapMode: Text.WordWrap
                width: scrollView.width
                Layout.maximumWidth: scrollView.width

                text: "<h2>Android OpenSSL support for Qt</h2><br>
<i>

                                 Apache License<br>
                           Version 2.0, January 2004<br>
                        https://www.apache.org/licenses/<br>

   TERMS AND CONDITIONS FOR USE, REPRODUCTION, AND DISTRIBUTION<br><br>

   1. Definitions.<br><br>

      \"License\" shall mean the terms and conditions for use, reproduction,
      and distribution as defined by Sections 1 through 9 of this document.

      \"Licensor\" shall mean the copyright owner or entity authorized by
      the copyright owner that is granting the License.<br><br>

      \"Legal Entity\" shall mean the union of the acting entity and all
      other entities that control, are controlled by, or are under common
      control with that entity. For the purposes of this definition,
      \"control\" means (i) the power, direct or indirect, to cause the
      direction or management of such entity, whether by contract or
      otherwise, or (ii) ownership of fifty percent (50%) or more of the
      outstanding shares, or (iii) beneficial ownership of such entity.<br><br>

      \"You\" (or \"Your\") shall mean an individual or Legal Entity
      exercising permissions granted by this License.<br><br>

      \"Source\" form shall mean the preferred form for making modifications,
      including but not limited to software source code, documentation
      source, and configuration files.<br><br>

      \"Object\" form shall mean any form resulting from mechanical
      transformation or translation of a Source form, including but
      not limited to compiled object code, generated documentation,
      and conversions to other media types.<br><br>

      \"Work\" shall mean the work of authorship, whether in Source or
      Object form, made available under the License, as indicated by a
      copyright notice that is included in or attached to the work
      (an example is provided in the Appendix below).<br><br>

      \"Derivative Works\" shall mean any work, whether in Source or Object
      form, that is based on (or derived from) the Work and for which the
      editorial revisions, annotations, elaborations, or other modifications
      represent, as a whole, an original work of authorship. For the purposes
      of this License, Derivative Works shall not include works that remain
      separable from, or merely link (or bind by name) to the interfaces of,
      the Work and Derivative Works thereof.<br><br>

      \"Contribution\" shall mean any work of authorship, including
      the original version of the Work and any modifications or additions
      to that Work or Derivative Works thereof, that is intentionally
      submitted to Licensor for inclusion in the Work by the copyright owner
      or by an individual or Legal Entity authorized to submit on behalf of
      the copyright owner. For the purposes of this definition, \"submitted\"
      means any form of electronic, verbal, or written communication sent
      to the Licensor or its representatives, including but not limited to
      communication on electronic mailing lists, source code control systems,
      and issue tracking systems that are managed by, or on behalf of, the
      Licensor for the purpose of discussing and improving the Work, but
      excluding communication that is conspicuously marked or otherwise
      designated in writing by the copyright owner as \"Not a Contribution.\"<br><br>

      \"Contributor\" shall mean Licensor and any individual or Legal Entity
      on behalf of whom a Contribution has been received by Licensor and
      subsequently incorporated within the Work.<br><br>

   2. Grant of Copyright License. Subject to the terms and conditions of
      this License, each Contributor hereby grants to You a perpetual,
      worldwide, non-exclusive, no-charge, royalty-free, irrevocable
      copyright license to reproduce, prepare Derivative Works of,
      publicly display, publicly perform, sublicense, and distribute the
      Work and such Derivative Works in Source or Object form.<br><br>

   3. Grant of Patent License. Subject to the terms and conditions of
      this License, each Contributor hereby grants to You a perpetual,
      worldwide, non-exclusive, no-charge, royalty-free, irrevocable
      (except as stated in this section) patent license to make, have made,
      use, offer to sell, sell, import, and otherwise transfer the Work,
      where such license applies only to those patent claims licensable
      by such Contributor that are necessarily infringed by their
      Contribution(s) alone or by combination of their Contribution(s)
      with the Work to which such Contribution(s) was submitted. If You
      institute patent litigation against any entity (including a
      cross-claim or counterclaim in a lawsuit) alleging that the Work
      or a Contribution incorporated within the Work constitutes direct
      or contributory patent infringement, then any patent licenses
      granted to You under this License for that Work shall terminate
      as of the date such litigation is filed.<br><br>

   4. Redistribution. You may reproduce and distribute copies of the
      Work or Derivative Works thereof in any medium, with or without
      modifications, and in Source or Object form, provided that You
      meet the following conditions:<br><br>

      (a) You must give any other recipients of the Work or
          Derivative Works a copy of this License; and<br><br>

      (b) You must cause any modified files to carry prominent notices
          stating that You changed the files; and<br><br>

      (c) You must retain, in the Source form of any Derivative Works
          that You distribute, all copyright, patent, trademark, and
          attribution notices from the Source form of the Work,
          excluding those notices that do not pertain to any part of
          the Derivative Works; and<br><br>

      (d) If the Work includes a \"NOTICE\" text file as part of its
          distribution, then any Derivative Works that You distribute must
          include a readable copy of the attribution notices contained
          within such NOTICE file, excluding those notices that do not
          pertain to any part of the Derivative Works, in at least one
          of the following places: within a NOTICE text file distributed
          as part of the Derivative Works; within the Source form or
          documentation, if provided along with the Derivative Works; or,
          within a display generated by the Derivative Works, if and
          wherever such third-party notices normally appear. The contents
          of the NOTICE file are for informational purposes only and
          do not modify the License. You may add Your own attribution
          notices within Derivative Works that You distribute, alongside
          or as an addendum to the NOTICE text from the Work, provided
          that such additional attribution notices cannot be construed
          as modifying the License.<br><br>

      You may add Your own copyright statement to Your modifications and
      may provide additional or different license terms and conditions
      for use, reproduction, or distribution of Your modifications, or
      for any such Derivative Works as a whole, provided Your use,
      reproduction, and distribution of the Work otherwise complies with
      the conditions stated in this License.<br><br>

   5. Submission of Contributions. Unless You explicitly state otherwise,
      any Contribution intentionally submitted for inclusion in the Work
      by You to the Licensor shall be under the terms and conditions of
      this License, without any additional terms or conditions.
      Notwithstanding the above, nothing herein shall supersede or modify
      the terms of any separate license agreement you may have executed
      with Licensor regarding such Contributions.<br><br>

   6. Trademarks. This License does not grant permission to use the trade
      names, trademarks, service marks, or product names of the Licensor,
      except as required for reasonable and customary use in describing the
      origin of the Work and reproducing the content of the NOTICE file.<br><br>

   7. Disclaimer of Warranty. Unless required by applicable law or
      agreed to in writing, Licensor provides the Work (and each
      Contributor provides its Contributions) on an \"AS IS\" BASIS,
      WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
      implied, including, without limitation, any warranties or conditions
      of TITLE, NON-INFRINGEMENT, MERCHANTABILITY, or FITNESS FOR A
      PARTICULAR PURPOSE. You are solely responsible for determining the
      appropriateness of using or redistributing the Work and assume any
      risks associated with Your exercise of permissions under this License.<br><br>

   8. Limitation of Liability. In no event and under no legal theory,
      whether in tort (including negligence), contract, or otherwise,
      unless required by applicable law (such as deliberate and grossly
      negligent acts) or agreed to in writing, shall any Contributor be
      liable to You for damages, including any direct, indirect, special,
      incidental, or consequential damages of any character arising as a
      result of this License or out of the use or inability to use the
      Work (including but not limited to damages for loss of goodwill,
      work stoppage, computer failure or malfunction, or any and all
      other commercial damages or losses), even if such Contributor
      has been advised of the possibility of such damages.<br><br>

   9. Accepting Warranty or Additional Liability. While redistributing
      the Work or Derivative Works thereof, You may choose to offer,
      and charge a fee for, acceptance of support, warranty, indemnity,
      or other liability obligations and/or rights consistent with this
      License. However, in accepting such obligations, You may act only
      on Your own behalf and on Your sole responsibility, not on behalf
      of any other Contributor, and only if You agree to indemnify,
      defend, and hold each Contributor harmless for any liability
      incurred by, or claims asserted against, such Contributor by reason
      of your accepting any such warranty or additional liability.<br><br>

   END OF TERMS AND CONDITIONS
<br><br>
</i>
               "
                color: "white"
            }

            Label {
                id: aboutShareUtils
                padding: 5
                wrapMode: Text.WordWrap
                width: scrollView.width
                Layout.maximumWidth: scrollView.width

                text: "<h2>ShareUtils</h2><br>
<i>
Copyright (c) 2014 Nicolas Froment<br><br>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the \"Software\"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions: <br><br>

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software. <br><br>

THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
<br><br>
</i>
               "
                color: "white"
            }

            Label {
                id: aboutFontAwesome
                padding: 5
                wrapMode: Text.WordWrap
                width: scrollView.width
                Layout.maximumWidth: scrollView.width

                text: "<h2>FontAwesome</h2><br>
<i>
Font Awesome Free License<br><br>

Font Awesome Free is free, open source, and GPL friendly. You can use it for
commercial projects, open source projects, or really almost whatever you want.
Full Font Awesome Free license: https://fontawesome.com/license/free.<br><br>

# Icons: CC BY 4.0 License (https://creativecommons.org/licenses/by/4.0/)<br>
In the Font Awesome Free download, the CC BY 4.0 license applies to all icons
packaged as SVG and JS file types.<br><br>

# Fonts: SIL OFL 1.1 License (https://scripts.sil.org/OFL)<br>
In the Font Awesome Free download, the SIL OFL license applies to all icons
packaged as web and desktop font files.<br><br>

# Code: MIT License (https://opensource.org/licenses/MIT)<br>
In the Font Awesome Free download, the MIT license applies to all non-font and
non-icon files.<br><br>

# Attribution<br>
Attribution is required by MIT, SIL OFL, and CC BY licenses. Downloaded Font
Awesome Free files already contain embedded comments with sufficient
attribution, so you shouldn't need to do anything additional when using these
files normally.<br><br>

We've kept attribution comments terse, so we ask that you do not actively work
to remove them from files, especially code. They're a great way for folks to
learn about Font Awesome.<br><br>

# Brand Icons<br>
All brand icons are trademarks of their respective owners. The use of these
trademarks does not indicate endorsement of the trademark holder by Font
Awesome, nor vice versa. **Please do not use brand logos for any purpose except
to represent the company, product, or service to which they refer.**<br><br>

<br><br>
</i>
               "
                color: "white"
            }
        }
    }
}
