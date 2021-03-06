//
//  TextTools.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 02/11/15.
//
//  The MIT License
//  Copyright (c) 2015 Maya Interactive. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
// Except as contained in this notice, the name of Maya Interactive and Meditation+
// shall not be used in advertising or otherwise to promote the sale, use or other
// dealings in this Software without prior written authorization from Maya Interactive.
//

import Foundation

public class TextTools
{
    static let sharedInstance = TextTools()

    lazy var regExp = {
        return try! NSRegularExpression(pattern: "\\(.*\\)|Q:|:\\)|:\\(|:D|8-\\)|:o|;\\(|:\\||:\\*|:P|:\\^\\)|\\|-\\)|\\|\\(|\\]:\\)|:@|:S|8-\\||:x", options: [])
    }()

    lazy var emoticons: [String:String] = {
        return [
            "Q:": "orange_q",
            ":)": "emoticon_00100_smile",
            ":(": "emoticon_00101_sadsmile",
            ":D": "emoticon_00102_bigsmile",
            "8-)": "emoticon_00103_cool",
            ":o": "emoticon_00105_wink",
            ";(": "emoticon_00106_crying",
            "(sweat)": "emoticon_00107_sweating",
            ":|": "emoticon_00108_speechless",
            ":*": "emoticon_00109_kiss",
            ":P": "emoticon_00110_tongueout",
            "(blush)": "emoticon_00111_blush",
            ":^)": "emoticon_00112_wondering",
            "|-)": "emoticon_00113_sleepy",
            "|(": "emoticon_00114_dull",
            "(inlove)": "emoticon_00115_inlove",
            "]:)": "emoticon_00116_evilgrin",
            "(talk)": "emoticon_00117_talking",
            "(yawn)": "emoticon_00118_yawn",
            "(puke)": "emoticon_00119_puke",
            "(doh)": "emoticon_00120_doh",
            ":@": "emoticon_00121_angry",
            "(wasntme)": "emoticon_00122_itwasntme",
            "(party)": "emoticon_00123_party",
            ":S": "emoticon_00124_worried",
            "(mm)": "emoticon_00125_mmm",
            "8-|": "emoticon_00126_nerd",
            ":x": "emoticon_00127_lipssealed",
            "(hi)": "emoticon_00128_hi",
            "(call)": "emoticon_00129_call",
            "(devil)": "emoticon_00130_devil",
            "(angel)": "emoticon_00131_angel",
            "(envy)": "emoticon_00132_envy",
            "(wait)": "emoticon_00133_wait",
            "(makeup)": "emoticon_00135_makeup",
            "(giggle)": "emoticon_00136_giggle",
            "(clap)": "emoticon_00137_clapping",
            "(think)": "emoticon_00138_thinking",
            "(rofl)": "emoticon_00140_rofl",
            "(whew)": "emoticon_00141_whew",
            "(happy)": "emoticon_00142_happy",
            "(smirk)": "emoticon_00143_smirk",
            "(nod)": "emoticon_00144_nod",
            "(shake)": "emoticon_00145_shake",
            "(punch)": "emoticon_00146_punch",
            "(emo)": "emoticon_00147_emo",
            "(highfive)": "highfive",
            "(facepalm)": "facepalm",
            "(fingers)": "fingerscrossed",
            "(lalala)": "lalala",
            "(waiting)": "waiting",
            "(headbang)": "emoticon_00179_headbang",
            "(fubar)": "emoticon_00181_fubar",
            "(swear)": "emoticon_00183_swear",
            "(tmi)": "emoticon_00184_tmi",
            "(rock)": "emoticon_00178_rock",
            "(peace)": "emoticon_peace",
            "(bow)": "emoticon_00139_bow",
            "(bear)": "emoticon_00134_bear",
            "(y)": "emoticon_00148_yes",
            "(n)": "emoticon_00149_no",
            "(handshake)": "emoticon_00150_handshake",
            "(h)": "emoticon_00152_heart",
            "(u)": "emoticon_00153_brokenheart",
            "(e)": "emoticon_00154_mail",
            "(f)": "emoticon_00155_flower",
            "(rain)": "emoticon_00156_rain",
            "(sun)": "emoticon_00157_sun",
            "(o)": "emoticon_00158_time",
            "(music)": "emoticon_00159_music",
            "(~)": "emoticon_00160_movie",
            "(mp)": "emoticon_00161_phone",
            "(coffee)": "emoticon_00162_coffee",
            "(pizza)": "emoticon_00163_pizza",
            "(cash)": "emoticon_00164_cash",
            "(muscle)": "emoticon_00165_muscle",
            "(^)": "emoticon_00166_cake",
            "(d)": "emoticon_00168_drink",
            "(dance)": "emoticon_00169_dance",
            "(ninja)": "emoticon_00170_ninja",
            "(*)": "emoticon_00171_star",
            "(toivo)": "emoticon_00177_toivo",
            "(bug)": "emoticon_00180_bug",
            "(poolparty)": "emoticon_00182_poolparty",
            "(heidy)": "emoticon_00185_heidy",
            "(tumbleweed)": "tumbleweed",
            "(wfh)": "wfh"
        ]
    }()
    
    /**
     Converts time in seconds to HH:mm:ss
     
     - parameter numSeconds: secoonds
     
     - returns: Formatted string
     */
    public func formattedTimeFromSeconds(numSeconds: NSTimeInterval) -> String
    {
        let seconds = numSeconds % 60;
        let hours   = numSeconds / 3600
        let minutes = numSeconds / 60 % 60
        return String(format: "%2.2d:%2.2d:%2.2d", Int(hours), Int(minutes), Int(seconds))
    }
}
