<section id="key">
    <a href="#date">Date</a><br>
    <a href="#name-abbreviation">Name and Abbreviation</a><br>
    <?php if (is_array($keys ?? '') && $keys !== []) {
        foreach ($keys as $key => $value) { ?>
        <a href="#<?= strtolower($value) ?>"><?= $key ?></a><br>
    <?php }
        } ?>
</section>
<section id="date">
    <h2>Date</h2>
    <p>Many municipal incorporation compilations use <span class="b">Incorporation Date</span>, generally based on the date of the incorporation law, court decree, proclamation, or local government enactment, in relation to events. In contrast, this resource uses <span class="b">Effective Date</span>, which is based on when an event took effect under law. These dates often differ, sometimes by over a year. When statutes provided for a transition period where a government existed as a legal entity for certain purposes but its territory retained its previous government temporarily, the date when this transition period ceased is used. In some cases, the actual effective date may be ambiguous, particularly when based on a clerical action such as filing or recording a document in a particular office. When this occurs, the best possible date is used. For transparency, how an effective date is determined is shown when possible.</p>
    <p>Under <span class="b">Event Year(s)</span>, this resource separately tracks the years between when a proposed change was initiated and when it either took effect or failed. When no effective date is entered, this year range is often used instead of the effective date. For sorting purposes, an exact sort date is assigned to each event, although the full sort date is only displayed in timelapses mapped in the Government pages.</p>
    <p>With three exceptions, dates are recorded using the calendar in effect at the time of the event or source document. For areas under British control, dates before the effective date of the <a href="https://en.wikipedia.org/wiki/Calendar_(New_Style)_Act_1750">Calendar (New Style) Act 1750</a> will use the Julian Calendar and will reflect the beginning of the year as March 25. The following exceptions to this rule substitute the <a href="https://en.wikipedia.org/wiki/Proleptic_Gregorian_calendar">Proleptic Gregorian calendar</a>:</p>
    <ul>
        <li>Years in the Statistics pages.</li>
        <li>Undisplayed sort dates.</li>
        <li>Timelapses mapped in the Government pages, which use sort dates.</li>
    </ul>
</section>
<section id="name-abbreviation">
    <h2>Name and Abbreviation</h2>
    <p>When possible, abbreviations used in this resource are modeled on the <a href="https://law.resource.org/pub/us/code/blue/IndigoBook.html">Indigo Book</a>. The names and types of governments are never abbreviated, although articles (e.g., "The") and formulaic portions of the corporate style, such as the "Mayor and Council of," are omitted. In particular, words such as <span style="font-weight: bold;">Mount</span> and <span style="font-weight: bold;">Saint</span> are spelled out in government names even if primary source documents abbreviate them.</p>
    <p>Some governments may have used different name spelling variants over time. If there is no evidence of a formal name change event and the variance in name spelling is minor, only the modern spelling is used.</p>
</section>