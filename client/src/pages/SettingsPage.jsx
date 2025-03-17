import React from 'react'
import { Scrollbars } from 'react-custom-scrollbars'
import SettingsDialog from '../components/dialogs/gameSettings'

function SettingsPage() {
  return (
    <Scrollbars style={{ ...styles.container }}>
      <SettingsDialog />
    </Scrollbars>
  )
}

export default SettingsPage

const styles = {
  container: {
    width: '100%',
    height: '100%',
    boxSizing: 'border-box'
  }
}