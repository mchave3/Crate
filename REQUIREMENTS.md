# Crate - Project Requirements & Specifications

## Document Information
- **Created**: May 30, 2025
- **Author**: Mickaël CHAVE
- **Version**: 1.0.0
- **Purpose**: Define detailed requirements and expectations for the Crate Windows ISO provisioning tool

---

## Project Vision

### Primary Objective
Modernize and improve an existing PowerShell WIM provisioning script by creating a maintainable PowerShell module with modular architecture. The goal is to retain the same functional principles but with better code organization and automation of cumulative update downloads.

### Historical Context
- **Existing Script**: PowerShell script of several hundred lines for WIM provisioning
- **Current Features**:
  - Listing available "Master" WIM files (with sizes, information)
  - Single or multiple WIM selection for processing
  - Index selection for each WIM
  - WIM Mount → Add cumulative updates → WIM Dismount
- **Current Limitation**: Need to manually download updates from Microsoft Update Catalog

### Target Users
- Mickaël CHAVE (primary user)
- System administrators with similar WIM provisioning needs

### Main Use Cases
1. **Automated WIM Provisioning**: Reproduce existing workflow but in an automated manner
2. **Update Management**: Automatic download of appropriate cumulative updates
3. **Multiple Selection and Processing**: Process multiple WIMs and indexes in a single execution
4. **Maintainable Architecture**: Replace monolithic script with structured module

---

## Core Workflow Requirements

## Core Workflow Requirements

### 1. Complete WIM Provisioning Workflow
Reproduce and improve the existing workflow with update automation:

**Steps Expected:**

1. **Master WIM Discovery and Listing**
   - Scan available "Master" WIM files in a configured directory
   - Display information: name, size, number of indexes, Windows version
   - Allow single or multiple WIM selection for processing

2. **Index Selection**
   - For each selected WIM, list available indexes
   - Allow selection of one or multiple indexes per WIM
   - Display index information (name, description, size)

3. **Automatic Update Search and Download**
   - Automatically identify appropriate cumulative updates for each WIM/index
   - Search Microsoft Update Catalog
   - Automatically download required updates
   - Manage local update cache

4. **WIM Provisioning**
   - Mount WIM image for selected index
   - Apply downloaded cumulative updates
   - Dismount and save modified WIM image
   - Repeat for all selected WIM/indexes

**User Experience:**
- Interface similar to existing script but more intuitive
- Clear progress for each step
- Ability to interrupt and resume operations
- Detailed logs for debugging

**Success Criteria:**
- Successful processing of all selected WIM/indexes
- Updates correctly applied and verified
- No manual intervention required for update downloads
- Optimized processing time compared to existing script

### 2. Individual Component Testing
Need for testing individual components during development and troubleshooting:

- **WIM Discovery Testing**: Test WIM scanning and information extraction
- **Update Search Testing**: Test automatic update detection for specific WIM versions
- **Download Testing**: Test update download mechanisms
- **Mount/Dismount Testing**: Test WIM mounting operations independently

### 3. Configuration Management
Configuration elements to manage:

- **Source Paths**: Configure directories containing Master WIM files
- **Update Cache**: Configure local cache location for downloaded updates
- **Update Sources**: Configure Microsoft Update Catalog endpoints or alternative sources
- **Processing Options**: Configure parallel processing, retry attempts, temporary directories

---

## Menu Structure Preferences

### Main Menu Philosophy
Simple and focused menu structure prioritizing the main workflow while providing access to administrative and testing functions. Preference for clear workflow-oriented options rather than technical component names.

### Priority Order
Based on frequency of use and workflow importance:

1. **Most Important**: Complete WIM Provisioning Workflow (primary use case)
2. **Secondary**: View Available WIM Masters, Manage Update Cache (preparation and maintenance)
3. **Administrative**: Configuration, Logs, Workspace Cleanup (occasional use)
4. **Help/Info**: Documentation, Status Information (as needed)

### Style Preferences
- Keep current emoji style for visual clarity and modern appearance
- Maintain professional yet approachable interface
- Clear action-oriented menu items
- Avoid overly technical terminology in main menu options

---

## Technical Requirements

### Input Sources
WIM file sources and management:

- [x] Local WIM files from configured directories
- [x] Multiple WIM versions simultaneously (Windows 10, 11, Server editions)
- [x] Support for standard Windows WIM file formats
- [ ] Network locations (future consideration)

### Update Sources
Update management and sources:

- [x] Microsoft Update Catalog (primary source)
- [x] Local update files (.msu, .cab) as backup/cache
- [x] Automatic cumulative update detection based on WIM version
- [ ] WSUS integration (future consideration)
- [ ] Manual update selection (advanced use case)

### Language Pack Sources
Language pack handling (future scope):

- [ ] Microsoft Language Portal
- [ ] Local language pack files
- [ ] Automatic detection based on region

### Output Options
WIM provisioning output:

- [x] Modified WIM files with updates applied
- [x] Preserve original WIM files (backup strategy)
- [x] Support for multiple index processing in single WIM
- [ ] Batch processing reports and logs

---

## User Experience Requirements

### Automation Level
Preferred level of automation for WIM provisioning:

- [x] Semi-automated (confirmation at key steps for safety)
- [x] Interactive (user choices for WIM/index selection)
- [x] Profile-based (saved configurations for repeated scenarios)
- [ ] Fully automated (minimal user interaction - future advanced mode)

### Error Handling
Error management and recovery mechanisms:

- [x] Automatic retry mechanisms for download failures
- [x] Rollback capabilities if provisioning fails
- [x] Resume interrupted operations (important for long processes)
- [x] Detailed error reporting with actionable information

### Progress Feedback
User feedback during operations:

- [x] Progress bars for long operations (mounting, downloading, applying updates)
- [x] Step-by-step status updates
- [x] Time estimates based on operation type and file sizes
- [x] Detailed logs in real-time for troubleshooting

---

## Development & Testing Requirements

### Development Tools Needed
Tools and features needed during development and troubleshooting:

- [x] Individual component testing (WIM discovery, update search, download, mount/dismount)
- [x] Mock data generation for testing without real WIM files
- [x] Performance profiling for optimization
- [x] Debug logging with verbose output
- [x] Dry-run mode (simulate operations without actual changes)

### Testing Scenarios
Testing scenarios to support during development:

- [x] WIM integrity validation before and after provisioning
- [x] Update compatibility testing (verify updates apply correctly)
- [x] Multiple WIM/index processing verification
- [x] End-to-end workflow testing with different Windows versions
- [x] Error simulation and recovery testing

---

## Integration Requirements

### External Tools
<!-- Quels outils externes devez-vous intégrer ? -->
- [ ] DISM (already planned)
- [ ] OSCDIMG (already planned)
- [ ] Windows ADK components
- [ ] Third-party tools

### System Integration
<!-- Comment intégrer avec le système ? -->
- [ ] Windows Event Logs
- [ ] System notifications
- [ ] Scheduled tasks
- [ ] Service mode operation

---

## Security & Compliance

### Security Requirements
<!-- Quelles exigences de sécurité ? -->
- [ ] Digital signature verification
- [ ] Hash validation
- [ ] Secure workspace management
- [ ] Audit trail

### Compliance Needs
<!-- Conformité nécessaire ? -->
- [ ] Corporate policies
- [ ] Regulatory requirements
- [ ] Industry standards

---

## Performance & Scalability

### Performance Targets
<!-- Quels sont vos objectifs de performance ? -->
- ISO processing time:
- Maximum file sizes:
- Concurrent operations:

### Resource Management
<!-- Comment gérer les ressources ? -->
- [ ] Disk space monitoring
- [ ] Memory usage optimization
- [ ] CPU utilization management
- [ ] Network bandwidth control

---

## Future Enhancements

### Planned Features
<!-- Quelles fonctionnalités futures envisagez-vous ? -->

### Integration Possibilities
<!-- Intégrations futures possibles ? -->

### Extensibility Needs
<!-- Le système doit-il être extensible ? -->

---

## Questions for Discussion

1. **Workflow Priority**: Quel est le workflow le plus important pour vous actuellement ?

2. **User Type**: Êtes-vous principalement un utilisateur technique ou voulez-vous que l'outil soit accessible à des non-experts ?

3. **Frequency of Use**: À quelle fréquence prévoyez-vous d'utiliser cet outil ?

4. **Integration Context**: Dans quel contexte utilisez-vous cet outil ? Environnement d'entreprise ? Personnel ? CI/CD ?

5. **Success Metrics**: Comment saurez-vous que Crate répond parfaitement à vos besoins ?

---

## Notes & Additional Comments

<!-- Ajoutez ici toute information supplémentaire, idées, ou commentaires -->
