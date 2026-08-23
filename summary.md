MAC Microbiome Study
================

## Datasets

- Data are from a 2 x 2 crossover design (AB/BA) with control/mac
  treatments ([Jones et al., 2023](https://doi.org/10.1017/jns.2023.39))

- Anthropometric data

  - Excel file `MAC Anthropometric data.xlsx`
  - Wide-format data for 35 unique participant IDs
  - Includes **BMI** and **percent body fat** (at `visit 0`, `clinic 4`,
    and `clinic 9`)
    - Also includes: weight (kg) and waist circumference (cm)

- Cardiometabolic data

  - Excel file `LLU_MAC Study_cardiometabolic outcomes.xlsx`
  - Long-format data for 38 unique participant IDs
    - Baseline (visit 0), Phase 1 (visit 4), Phase 2 (visit 9), and
      clinic date
  - Includes **total cholesterol**, **LDL**, **HDL**, and **ApoB**
    - Also includes: glucose, insulin, triglycerides, VLDL, ApoA1, CRP,
      and E-selectin

- Microbiome data

  - Excel file `human_mac_study_abundance_data.xls`
  - Wide-format data with 4,166 bacteria species/ASVs, including
    **Roseburia**
  - The first 7 columns are: `Domain`, `Phylum`, `Class`, `Order`,
    `Family`, `Genus`, and `Species`
  - Abundance values at visits 0, 4, and 9 are stored in the 105 columns
    that follow, named:
    - MAC\[*ID_in_2digits*\]\_p1\[*v0/v4/v9*\]

- To extract participants’ treatment sequence, use:

  - SPSS data file `MAC Endpoint data with baseline values 102121.sav`
  - Participant characteristics were also extracted from this file
    - Sex, age at baseline, and weight at baseline

- Data files were merged to produce a long-format dataset

  - 105 observations (3 visits, including baseline, × 35 participants)

## Descriptive table at baseline

- Descriptive statistics at baseline by sequence
  - \[**Need to check**\] Descriptive statistics on percent body fat are
    slightly off, compared to the original paper ([Jones et al.,
    2023](https://doi.org/10.1017/jns.2023.39))

<div id="kvhleyrpoc" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
<style>#kvhleyrpoc table {
  font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}
&#10;#kvhleyrpoc thead, #kvhleyrpoc tbody, #kvhleyrpoc tfoot, #kvhleyrpoc tr, #kvhleyrpoc td, #kvhleyrpoc th {
  border-style: none;
}
&#10;#kvhleyrpoc p {
  margin: 0;
  padding: 0;
}
&#10;#kvhleyrpoc .gt_table {
  display: table;
  border-collapse: collapse;
  line-height: normal;
  margin-left: auto;
  margin-right: auto;
  color: #333333;
  font-size: 16px;
  font-weight: normal;
  font-style: normal;
  background-color: #FFFFFF;
  width: auto;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #A8A8A8;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #A8A8A8;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
}
&#10;#kvhleyrpoc .gt_caption {
  padding-top: 4px;
  padding-bottom: 4px;
}
&#10;#kvhleyrpoc .gt_title {
  color: #333333;
  font-size: 125%;
  font-weight: initial;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-color: #FFFFFF;
  border-bottom-width: 0;
}
&#10;#kvhleyrpoc .gt_subtitle {
  color: #333333;
  font-size: 85%;
  font-weight: initial;
  padding-top: 3px;
  padding-bottom: 5px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-color: #FFFFFF;
  border-top-width: 0;
}
&#10;#kvhleyrpoc .gt_heading {
  background-color: #FFFFFF;
  text-align: left;
  border-bottom-color: #FFFFFF;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}
&#10;#kvhleyrpoc .gt_bottom_border {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}
&#10;#kvhleyrpoc .gt_col_headings {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}
&#10;#kvhleyrpoc .gt_col_heading {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  overflow-x: hidden;
}
&#10;#kvhleyrpoc .gt_column_spanner_outer {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  padding-top: 0;
  padding-bottom: 0;
  padding-left: 4px;
  padding-right: 4px;
}
&#10;#kvhleyrpoc .gt_column_spanner_outer:first-child {
  padding-left: 0;
}
&#10;#kvhleyrpoc .gt_column_spanner_outer:last-child {
  padding-right: 0;
}
&#10;#kvhleyrpoc .gt_column_spanner {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 5px;
  overflow-x: hidden;
  display: inline-block;
  width: 100%;
}
&#10;#kvhleyrpoc .gt_spanner_row {
  border-bottom-style: hidden;
}
&#10;#kvhleyrpoc .gt_group_heading {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  text-align: left;
}
&#10;#kvhleyrpoc .gt_empty_group_heading {
  padding: 0.5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: middle;
}
&#10;#kvhleyrpoc .gt_from_md > :first-child {
  margin-top: 0;
}
&#10;#kvhleyrpoc .gt_from_md > :last-child {
  margin-bottom: 0;
}
&#10;#kvhleyrpoc .gt_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  margin: 10px;
  border-top-style: solid;
  border-top-width: 1px;
  border-top-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  overflow-x: hidden;
}
&#10;#kvhleyrpoc .gt_stub {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#kvhleyrpoc .gt_stub_row_group {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
  vertical-align: top;
}
&#10;#kvhleyrpoc .gt_row_group_first td {
  border-top-width: 2px;
}
&#10;#kvhleyrpoc .gt_row_group_first th {
  border-top-width: 2px;
}
&#10;#kvhleyrpoc .gt_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#kvhleyrpoc .gt_first_summary_row {
  border-top-style: solid;
  border-top-color: #D3D3D3;
}
&#10;#kvhleyrpoc .gt_first_summary_row.thick {
  border-top-width: 2px;
}
&#10;#kvhleyrpoc .gt_last_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}
&#10;#kvhleyrpoc .gt_grand_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#kvhleyrpoc .gt_first_grand_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: double;
  border-top-width: 6px;
  border-top-color: #D3D3D3;
}
&#10;#kvhleyrpoc .gt_last_grand_summary_row_top {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: double;
  border-bottom-width: 6px;
  border-bottom-color: #D3D3D3;
}
&#10;#kvhleyrpoc .gt_striped {
  background-color: rgba(128, 128, 128, 0.05);
}
&#10;#kvhleyrpoc .gt_table_body {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}
&#10;#kvhleyrpoc .gt_footnotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}
&#10;#kvhleyrpoc .gt_footnote {
  margin: 0px;
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#kvhleyrpoc .gt_sourcenotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}
&#10;#kvhleyrpoc .gt_sourcenote {
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#kvhleyrpoc .gt_left {
  text-align: left;
}
&#10;#kvhleyrpoc .gt_center {
  text-align: center;
}
&#10;#kvhleyrpoc .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}
&#10;#kvhleyrpoc .gt_font_normal {
  font-weight: normal;
}
&#10;#kvhleyrpoc .gt_font_bold {
  font-weight: bold;
}
&#10;#kvhleyrpoc .gt_font_italic {
  font-style: italic;
}
&#10;#kvhleyrpoc .gt_super {
  font-size: 65%;
}
&#10;#kvhleyrpoc .gt_footnote_marks {
  font-size: 75%;
  vertical-align: 0.4em;
  position: initial;
}
&#10;#kvhleyrpoc .gt_asterisk {
  font-size: 100%;
  vertical-align: 0;
}
&#10;#kvhleyrpoc .gt_indent_1 {
  text-indent: 5px;
}
&#10;#kvhleyrpoc .gt_indent_2 {
  text-indent: 10px;
}
&#10;#kvhleyrpoc .gt_indent_3 {
  text-indent: 15px;
}
&#10;#kvhleyrpoc .gt_indent_4 {
  text-indent: 20px;
}
&#10;#kvhleyrpoc .gt_indent_5 {
  text-indent: 25px;
}
&#10;#kvhleyrpoc .katex-display {
  display: inline-flex !important;
  margin-bottom: 0.75em !important;
}
&#10;#kvhleyrpoc div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
  height: 0px !important;
}
</style>
<table class="gt_table" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
  <thead>
    <tr class="gt_heading">
      <td colspan="5" class="gt_heading gt_title gt_font_normal gt_bottom_border" style>Participant characteristics at baseline</td>
    </tr>
    &#10;    <tr class="gt_col_headings">
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="label"><span class='gt_from_md'><strong>Characteristic</strong></span></th>
      <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" scope="col" id="stat_0"><span class='gt_from_md'><strong>Overall</strong><br />
N = 35</span><span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;line-height:0;"><sup>1</sup></span></th>
      <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" scope="col" id="stat_1"><span class='gt_from_md'><strong>mac-control</strong><br />
N = 18</span><span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;line-height:0;"><sup>1</sup></span></th>
      <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" scope="col" id="stat_2"><span class='gt_from_md'><strong>control-mac</strong><br />
N = 17</span><span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;line-height:0;"><sup>1</sup></span></th>
      <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" scope="col" id="p.value"><span class='gt_from_md'><strong>p-value</strong></span><span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;line-height:0;"><sup>2</sup></span></th>
    </tr>
  </thead>
  <tbody class="gt_table_body">
    <tr><td headers="label" class="gt_row gt_left" style="font-weight: bold;">Age (years)</td>
<td headers="stat_0" class="gt_row gt_center">61.7 (8.3)</td>
<td headers="stat_1" class="gt_row gt_center">62.4 (7.8)</td>
<td headers="stat_2" class="gt_row gt_center">61.0 (9.1)</td>
<td headers="p.value" class="gt_row gt_center">0.6313</td></tr>
    <tr><td headers="label" class="gt_row gt_left" style="font-weight: bold;">Sex</td>
<td headers="stat_0" class="gt_row gt_center"><br /></td>
<td headers="stat_1" class="gt_row gt_center"><br /></td>
<td headers="stat_2" class="gt_row gt_center"><br /></td>
<td headers="p.value" class="gt_row gt_center">0.6906</td></tr>
    <tr><td headers="label" class="gt_row gt_left">    F</td>
<td headers="stat_0" class="gt_row gt_center">28 (80%)</td>
<td headers="stat_1" class="gt_row gt_center">15 (83%)</td>
<td headers="stat_2" class="gt_row gt_center">13 (76%)</td>
<td headers="p.value" class="gt_row gt_center"><br /></td></tr>
    <tr><td headers="label" class="gt_row gt_left">    M</td>
<td headers="stat_0" class="gt_row gt_center">7 (20%)</td>
<td headers="stat_1" class="gt_row gt_center">3 (17%)</td>
<td headers="stat_2" class="gt_row gt_center">4 (24%)</td>
<td headers="p.value" class="gt_row gt_center"><br /></td></tr>
    <tr><td headers="label" class="gt_row gt_left" style="font-weight: bold;">Weight (kg)</td>
<td headers="stat_0" class="gt_row gt_center">83.3 (14.1)</td>
<td headers="stat_1" class="gt_row gt_center">84.5 (14.7)</td>
<td headers="stat_2" class="gt_row gt_center">82.0 (13.7)</td>
<td headers="p.value" class="gt_row gt_center">0.6069</td></tr>
    <tr><td headers="label" class="gt_row gt_left" style="font-weight: bold;">BMI (kg/m²)</td>
<td headers="stat_0" class="gt_row gt_center">30.3 (3.4)</td>
<td headers="stat_1" class="gt_row gt_center">30.2 (3.7)</td>
<td headers="stat_2" class="gt_row gt_center">30.4 (3.3)</td>
<td headers="p.value" class="gt_row gt_center">0.9050</td></tr>
    <tr><td headers="label" class="gt_row gt_left" style="font-weight: bold;">Body fat (%)</td>
<td headers="stat_0" class="gt_row gt_center">42.3 (5.8)</td>
<td headers="stat_1" class="gt_row gt_center">41.8 (5.5)</td>
<td headers="stat_2" class="gt_row gt_center">42.8 (6.2)</td>
<td headers="p.value" class="gt_row gt_center">0.6122</td></tr>
    <tr><td headers="label" class="gt_row gt_left" style="font-weight: bold;">Total cholesterol (mg/dL)</td>
<td headers="stat_0" class="gt_row gt_center">204.2 (29.6)</td>
<td headers="stat_1" class="gt_row gt_center">199.2 (29.4)</td>
<td headers="stat_2" class="gt_row gt_center">209.5 (29.9)</td>
<td headers="p.value" class="gt_row gt_center">0.3138</td></tr>
    <tr><td headers="label" class="gt_row gt_left" style="font-weight: bold;">LDL cholesterol (mg/dL)</td>
<td headers="stat_0" class="gt_row gt_center">121.0 (27.7)</td>
<td headers="stat_1" class="gt_row gt_center">114.6 (27.5)</td>
<td headers="stat_2" class="gt_row gt_center">127.8 (27.1)</td>
<td headers="p.value" class="gt_row gt_center">0.1614</td></tr>
    <tr><td headers="label" class="gt_row gt_left" style="font-weight: bold;">HDL cholesterol (mg/dL)</td>
<td headers="stat_0" class="gt_row gt_center">56.8 (11.4)</td>
<td headers="stat_1" class="gt_row gt_center">56.7 (9.3)</td>
<td headers="stat_2" class="gt_row gt_center">56.9 (13.7)</td>
<td headers="p.value" class="gt_row gt_center">0.9453</td></tr>
    <tr><td headers="label" class="gt_row gt_left" style="font-weight: bold;">ApoB (mg/dL)</td>
<td headers="stat_0" class="gt_row gt_center">104.9 (16.8)</td>
<td headers="stat_1" class="gt_row gt_center">101.9 (16.4)</td>
<td headers="stat_2" class="gt_row gt_center">108.0 (17.2)</td>
<td headers="p.value" class="gt_row gt_center">0.2946</td></tr>
  </tbody>
  <tfoot>
    <tr class="gt_footnotes">
      <td class="gt_footnote" colspan="5"><span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;line-height:0;"><sup>1</sup></span> <span class='gt_from_md'>Mean (SD); n (%)</span></td>
    </tr>
    <tr class="gt_footnotes">
      <td class="gt_footnote" colspan="5"><span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;line-height:0;"><sup>2</sup></span> <span class='gt_from_md'>Welch Two Sample t-test; Fisher’s exact test</span></td>
    </tr>
  </tfoot>
</table>
</div>

## Exploratory analyses

### Cardiometabolic variables

- Distributions of cardiometabolic measurements (excluding baseline)

![](summary_files/figure-gfm/histogram_cardiometabolic-1.png)<!-- -->

- Profile plots of cardiometabolic measurements by sequence
  - Each line represents a participant
  - Visualize individual-level change across phases
    - All within-person changes across phases fall within a
      physiologically plausible range

![](summary_files/figure-gfm/profile_plots_cardiometabolic-1.png)<!-- -->

- Waterfall plots of within-person change (mac − control) across four
  cardiometabolic outcomes
  - Each bar represents one participant’s change score, sorted from most
    negative to most positive
  - Visualize the direction and magnitude of individual treatment
    response, and whether response is consistent across the cohort or
    driven by a subset of participants

![](summary_files/figure-gfm/waterfall_plot_cardiometabolic-1.png)<!-- -->

- Mean (SD) within-person change (mac − control) for total cholesterol,
  LDL, HDL, and ApoB

<div id="hkfoedaiik" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
<style>#hkfoedaiik table {
  font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}
&#10;#hkfoedaiik thead, #hkfoedaiik tbody, #hkfoedaiik tfoot, #hkfoedaiik tr, #hkfoedaiik td, #hkfoedaiik th {
  border-style: none;
}
&#10;#hkfoedaiik p {
  margin: 0;
  padding: 0;
}
&#10;#hkfoedaiik .gt_table {
  display: table;
  border-collapse: collapse;
  line-height: normal;
  margin-left: auto;
  margin-right: auto;
  color: #333333;
  font-size: 16px;
  font-weight: normal;
  font-style: normal;
  background-color: #FFFFFF;
  width: auto;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #A8A8A8;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #A8A8A8;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
}
&#10;#hkfoedaiik .gt_caption {
  padding-top: 4px;
  padding-bottom: 4px;
}
&#10;#hkfoedaiik .gt_title {
  color: #333333;
  font-size: 125%;
  font-weight: initial;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-color: #FFFFFF;
  border-bottom-width: 0;
}
&#10;#hkfoedaiik .gt_subtitle {
  color: #333333;
  font-size: 85%;
  font-weight: initial;
  padding-top: 3px;
  padding-bottom: 5px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-color: #FFFFFF;
  border-top-width: 0;
}
&#10;#hkfoedaiik .gt_heading {
  background-color: #FFFFFF;
  text-align: center;
  border-bottom-color: #FFFFFF;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}
&#10;#hkfoedaiik .gt_bottom_border {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}
&#10;#hkfoedaiik .gt_col_headings {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}
&#10;#hkfoedaiik .gt_col_heading {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  overflow-x: hidden;
}
&#10;#hkfoedaiik .gt_column_spanner_outer {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  padding-top: 0;
  padding-bottom: 0;
  padding-left: 4px;
  padding-right: 4px;
}
&#10;#hkfoedaiik .gt_column_spanner_outer:first-child {
  padding-left: 0;
}
&#10;#hkfoedaiik .gt_column_spanner_outer:last-child {
  padding-right: 0;
}
&#10;#hkfoedaiik .gt_column_spanner {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 5px;
  overflow-x: hidden;
  display: inline-block;
  width: 100%;
}
&#10;#hkfoedaiik .gt_spanner_row {
  border-bottom-style: hidden;
}
&#10;#hkfoedaiik .gt_group_heading {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  text-align: left;
}
&#10;#hkfoedaiik .gt_empty_group_heading {
  padding: 0.5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: middle;
}
&#10;#hkfoedaiik .gt_from_md > :first-child {
  margin-top: 0;
}
&#10;#hkfoedaiik .gt_from_md > :last-child {
  margin-bottom: 0;
}
&#10;#hkfoedaiik .gt_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  margin: 10px;
  border-top-style: solid;
  border-top-width: 1px;
  border-top-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  overflow-x: hidden;
}
&#10;#hkfoedaiik .gt_stub {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#hkfoedaiik .gt_stub_row_group {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
  vertical-align: top;
}
&#10;#hkfoedaiik .gt_row_group_first td {
  border-top-width: 2px;
}
&#10;#hkfoedaiik .gt_row_group_first th {
  border-top-width: 2px;
}
&#10;#hkfoedaiik .gt_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#hkfoedaiik .gt_first_summary_row {
  border-top-style: solid;
  border-top-color: #D3D3D3;
}
&#10;#hkfoedaiik .gt_first_summary_row.thick {
  border-top-width: 2px;
}
&#10;#hkfoedaiik .gt_last_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}
&#10;#hkfoedaiik .gt_grand_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#hkfoedaiik .gt_first_grand_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: double;
  border-top-width: 6px;
  border-top-color: #D3D3D3;
}
&#10;#hkfoedaiik .gt_last_grand_summary_row_top {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: double;
  border-bottom-width: 6px;
  border-bottom-color: #D3D3D3;
}
&#10;#hkfoedaiik .gt_striped {
  background-color: rgba(128, 128, 128, 0.05);
}
&#10;#hkfoedaiik .gt_table_body {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}
&#10;#hkfoedaiik .gt_footnotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}
&#10;#hkfoedaiik .gt_footnote {
  margin: 0px;
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#hkfoedaiik .gt_sourcenotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}
&#10;#hkfoedaiik .gt_sourcenote {
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#hkfoedaiik .gt_left {
  text-align: left;
}
&#10;#hkfoedaiik .gt_center {
  text-align: center;
}
&#10;#hkfoedaiik .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}
&#10;#hkfoedaiik .gt_font_normal {
  font-weight: normal;
}
&#10;#hkfoedaiik .gt_font_bold {
  font-weight: bold;
}
&#10;#hkfoedaiik .gt_font_italic {
  font-style: italic;
}
&#10;#hkfoedaiik .gt_super {
  font-size: 65%;
}
&#10;#hkfoedaiik .gt_footnote_marks {
  font-size: 75%;
  vertical-align: 0.4em;
  position: initial;
}
&#10;#hkfoedaiik .gt_asterisk {
  font-size: 100%;
  vertical-align: 0;
}
&#10;#hkfoedaiik .gt_indent_1 {
  text-indent: 5px;
}
&#10;#hkfoedaiik .gt_indent_2 {
  text-indent: 10px;
}
&#10;#hkfoedaiik .gt_indent_3 {
  text-indent: 15px;
}
&#10;#hkfoedaiik .gt_indent_4 {
  text-indent: 20px;
}
&#10;#hkfoedaiik .gt_indent_5 {
  text-indent: 25px;
}
&#10;#hkfoedaiik .katex-display {
  display: inline-flex !important;
  margin-bottom: 0.75em !important;
}
&#10;#hkfoedaiik div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
  height: 0px !important;
}
</style>
<table class="gt_table" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
  <thead>
    <tr class="gt_col_headings">
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="label"><span class='gt_from_md'><strong>Outcome</strong></span></th>
      <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" scope="col" id="stat_0"><span class='gt_from_md'><strong>N = 35</strong></span><span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;line-height:0;"><sup>1</sup></span></th>
    </tr>
  </thead>
  <tbody class="gt_table_body">
    <tr><td headers="label" class="gt_row gt_left" style="font-weight: bold;">Δ Total cholesterol (mac-control)</td>
<td headers="stat_0" class="gt_row gt_center">-4.5 (30.4)</td></tr>
    <tr><td headers="label" class="gt_row gt_left" style="font-weight: bold;">Δ LDL cholesterol (mac-control)</td>
<td headers="stat_0" class="gt_row gt_center">-4.9 (27.9)</td></tr>
    <tr><td headers="label" class="gt_row gt_left" style="font-weight: bold;">Δ HDL cholesterol (mac-control)</td>
<td headers="stat_0" class="gt_row gt_center">-0.3 (5.5)</td></tr>
    <tr><td headers="label" class="gt_row gt_left" style="font-weight: bold;">Δ ApoB (mac-control)</td>
<td headers="stat_0" class="gt_row gt_center">-1.0 (12.1)</td></tr>
  </tbody>
  <tfoot>
    <tr class="gt_footnotes">
      <td class="gt_footnote" colspan="2"><span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;line-height:0;"><sup>1</sup></span> <span class='gt_from_md'>Mean (SD)</span></td>
    </tr>
  </tfoot>
</table>
</div>

### Microbiome variables

- Only focusing on **Roseburia_2** for now. See the distribution below,
  excluding baseline:
  - The x-axis is on the pseudo-log scale
  - Note that there are \>25 zero counts

![](summary_files/figure-gfm/histogram_roseburia_2-1.png)<!-- -->

- There are 11 participants with **Roseburia_2** = 0 in both phases
- Six participants have **Roseburia_2 = 0** in only one of the two
  phases
  - Incidentally, in all six cases, the zero occurred under the control
    treatment, not the macadamia treatment

<table class="kable_wrapper">

<tbody>

<tr>

<td>

|  id | group_lab   | phase_1 | phase_2 |
|----:|:------------|--------:|--------:|
|   1 | control-mac |       0 |       0 |
|   7 | control-mac |       0 |       0 |
|  18 | mac-control |       0 |       0 |
|  23 | control-mac |       0 |       0 |
|  28 | mac-control |       0 |       0 |
|  32 | mac-control |       0 |       0 |
|  35 | control-mac |       0 |       0 |
|  37 | mac-control |       0 |       0 |
|  38 | control-mac |       0 |       0 |
|  41 | control-mac |       0 |       0 |
|  42 | mac-control |       0 |       0 |

Zero in both phases

</td>

<td>

|  id | group_lab   | phase_1 | phase_2 |
|----:|:------------|--------:|--------:|
|  19 | mac-control |      83 |       0 |
|  20 | mac-control |      51 |       0 |
|  26 | control-mac |       0 |     311 |
|  31 | mac-control |     530 |       0 |
|  34 | mac-control |     274 |       0 |
|  40 | control-mac |       0 |     427 |

Zero in one phase

</td>

</tr>

</tbody>

</table>

- Profile plots of **Roseburia_2** by sequence
  - Shows higher **Roseburia_2** abundance under the macadamia diet
  - The flat lines at zero correspond to the 11 participants with
    Roseburia_2 = 0 in both phases (see table above)
  - Note: the y-axis uses a pseudo-log scale to accommodate true zeros,
    so visual distances near the bottom of the axis are
    compressed/expanded non-linearly relative to distances higher up
    - A line rising from 0 shouldn’t be read as directly comparable in
      magnitude to, say, a line rising from 300 to 1000

![](summary_files/figure-gfm/profile_plot_roseburia_2-1.png)<!-- -->
